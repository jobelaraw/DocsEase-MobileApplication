const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten, onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const crypto = require("crypto");
const { Translate } = require("@google-cloud/translate").v2;

admin.initializeApp();
const translate = new Translate();

exports.resetUserPassword = onCall(async (request) => {
    console.log("Incoming request data:", request.data);

    const email = request.data.email;
    const enteredCode = request.data.otp;
    const newPassword = request.data.newPassword;

    if (!email || email.trim() === "") {
        throw new HttpsError('invalid-argument', 'Backend received a blank email! The app lost the email variable in memory.');
    }

    const docRef = admin.firestore().collection('recovery_codes').doc(email);
    const docSnap = await docRef.get();

    if (!docSnap.exists || docSnap.data().code !== enteredCode) {
        throw new HttpsError('permission-denied', 'Invalid or expired OTP code.');
    }

    const userRecord = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(userRecord.uid, {
        password: newPassword
    });

    await docRef.delete();
    return { success: true };
});

const EMAILJS_PRIVATE_KEY = defineSecret("EMAILJS_PRIVATE_KEY");
const EMAILJS_SERVICE_ID = "service_2qau4rv";
const EMAILJS_TEMPLATE_ID = "template_fsgox73";
const EMAILJS_PUBLIC_KEY = "KA-6Zx9c2My5ohVje"; 

const RESET_COLLECTION = "password_resets";
const CODE_TTL_MS = 5 * 60 * 1000;      // code valid for 5 minutes
const RESEND_COOLDOWN_MS = 60 * 1000;    
const MAX_ATTEMPTS = 5;                
const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$/;

function normalizeEmail(v) {
    return String(v || "").trim().toLowerCase();
}

function generateCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let out = "";
    for (let i = 0; i < 6; i++) out += chars[crypto.randomInt(chars.length)];
    return out;
}

function hashCode(code, salt) {
    return crypto.createHash("sha256").update(salt + String(code).trim().toUpperCase()).digest("hex");
}

function safeEqualHex(a, b) {
    const ba = Buffer.from(a, "hex");
    const bb = Buffer.from(b, "hex");
    return ba.length === bb.length && crypto.timingSafeEqual(ba, bb);
}

async function checkCode(email, code) {
    const db = admin.firestore();
    const ref = db.collection(RESET_COLLECTION).doc(email);
    return db.runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists) return { ok: false, reason: "no-code" };
        const d = snap.data();

        if (d.expiresAt.toMillis() < Date.now()) {
            tx.delete(ref);
            return { ok: false, reason: "expired" };
        }
        if (safeEqualHex(hashCode(code, d.salt), d.codeHash)) return { ok: true };

        const attempts = (d.attempts || 0) + 1;
        if (attempts >= MAX_ATTEMPTS) {
            tx.delete(ref);
            return { ok: false, reason: "too-many-attempts" };
        }
        tx.update(ref, { attempts });
        return { ok: false, reason: "wrong-code", attemptsLeft: MAX_ATTEMPTS - attempts };
    });
}

function throwForFailedCheck(result) {
    switch (result.reason) {
        case "wrong-code":
            throw new HttpsError("permission-denied", "Incorrect code.", { attemptsLeft: result.attemptsLeft });
        case "too-many-attempts":
            throw new HttpsError("resource-exhausted", "Too many wrong attempts. Please request a new code.");
        default: // no-code / expired
            throw new HttpsError("failed-precondition", "This code has expired. Please request a new one.");
    }
}

// Generate + store (hashed) + email the code. Used by first send AND resend.
exports.sendRecoveryCode = onCall({ secrets: [EMAILJS_PRIVATE_KEY] }, async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    if (!EMAIL_RE.test(email)) throw new HttpsError("invalid-argument", "Please enter a valid email.");

    try {
        await admin.auth().getUserByEmail(email);
    } catch (e) {
        if (e.code === "auth/user-not-found") throw new HttpsError("not-found", "This email does not exist.");
        console.error("getUserByEmail failed:", e);
        throw new HttpsError("internal", "Lookup failed.");
    }

    const ref = admin.firestore().collection(RESET_COLLECTION).doc(email);
    const existing = await ref.get();
    if (existing.exists && existing.data().lastSentAt) {
        const waitMs = RESEND_COOLDOWN_MS - (Date.now() - existing.data().lastSentAt.toMillis());
        if (waitMs > 0) {
            const secs = Math.ceil(waitMs / 1000);
            throw new HttpsError("resource-exhausted", `Please wait ${secs} seconds before requesting another code.`, { retryAfterSeconds: secs });
        }
    }

    const code = generateCode();
    const salt = crypto.randomBytes(16).toString("hex");
    const now = Date.now();
    await ref.set({
        codeHash: hashCode(code, salt),
        salt,
        attempts: 0,
        createdAt: admin.firestore.Timestamp.fromMillis(now),
        lastSentAt: admin.firestore.Timestamp.fromMillis(now),
        expiresAt: admin.firestore.Timestamp.fromMillis(now + CODE_TTL_MS),
    });

    try {
        const res = await fetch("https://api.emailjs.com/api/v1.0/email/send", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            signal: AbortSignal.timeout(15000),
            body: JSON.stringify({
                service_id: EMAILJS_SERVICE_ID,
                template_id: EMAILJS_TEMPLATE_ID,
                user_id: EMAILJS_PUBLIC_KEY,
                accessToken: EMAILJS_PRIVATE_KEY.value(),
                template_params: { to_email: email, recovery_code: code },
            }),
        });
        if (!res.ok) {
            console.error("EmailJS rejected the request:", res.status, await res.text());
            await ref.delete();
            throw new HttpsError("unavailable", `Email service error (${res.status}).`, { status: res.status });
        }
    } catch (e) {
        if (e instanceof HttpsError) throw e;
        console.error("EmailJS request failed:", e);
        await ref.delete();
        throw new HttpsError("unavailable", "Could not reach the email service.");
    }

    return { ok: true, expiresInSeconds: CODE_TTL_MS / 1000 };
});

// 2) Verify the code (UI step). Does NOT consume the code; reset re-checks it.
exports.verifyRecoveryCode = onCall(async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    const code = request.data && request.data.code;
    if (!EMAIL_RE.test(email) || !code) throw new HttpsError("invalid-argument", "Email and code are required.");

    const result = await checkCode(email, code);
    if (!result.ok) throwForFailedCheck(result);
    return { valid: true };
});

// 3) Verify again + set the new password + burn the code.
exports.resetPasswordWithCode = onCall(async (request) => {
    const email = normalizeEmail(request.data && request.data.email);
    const code = request.data && request.data.code;
    const newPassword = request.data && request.data.newPassword;
    if (!EMAIL_RE.test(email) || !code) throw new HttpsError("invalid-argument", "Email and code are required.");
    if (typeof newPassword !== "string" || newPassword.length < 8) {
        throw new HttpsError("invalid-argument", "Password must be at least 8 characters.");
    }

    const result = await checkCode(email, code);
    if (!result.ok) throwForFailedCheck(result);

    let user;
    try {
        user = await admin.auth().getUserByEmail(email);
    } catch (e) {
        throw new HttpsError("not-found", "This email does not exist.");
    }
    await admin.auth().updateUser(user.uid, { password: newPassword });
    await admin.auth().revokeRefreshTokens(user.uid); // sign out other sessions
    await admin.firestore().collection(RESET_COLLECTION).doc(email).delete();
    return { success: true };
});

// 4) Signed-in password change (Edit Profile). Uses the caller's own email.
exports.changePasswordWithCode = onCall(async (request) => {
    if (!request.auth || !request.auth.token.email) {
        throw new HttpsError("unauthenticated", "Please sign in again.");
    }
    const email = normalizeEmail(request.auth.token.email);
    const code = request.data && request.data.code;
    const newPassword = request.data && request.data.newPassword;

    if (!code) throw new HttpsError("invalid-argument", "Verification code is required.");
    if (typeof newPassword !== "string" || newPassword.length < 8) {
        throw new HttpsError("invalid-argument", "Password must be at least 8 characters.");
    }

    const result = await checkCode(email, code);
    if (!result.ok) throwForFailedCheck(result);

    await admin.auth().updateUser(request.auth.uid, { password: newPassword });
    await admin.firestore().collection(RESET_COLLECTION).doc(email).delete();
    return { success: true };
});

// Look up which sign-in methods an email has (used by the app's auth screens)
exports.isEmailRegistered = onCall(async (request) => {
    const email = (request.data.email || "").trim().toLowerCase();
    if (!email) return { exists: false, providers: [] };
    try {
        const user = await admin.auth().getUserByEmail(email);
        return {
            exists: true,
            providers: user.providerData.map((p) => p.providerId), // 'password', 'google.com'
        };
    } catch (e) {
        if (e.code === "auth/user-not-found") return { exists: false, providers: [] };
        throw new HttpsError("internal", "Lookup failed");
    }
});

// Helper: Translate a string to Filipino
async function translateToFilipino(text) {
    if (!text || text.trim() === "") return "";
    try {
        const [translation] = await translate.translate(text, "tl");
        return translation;
    } catch (e) {
        console.error("Translation error:", e);
        return text; // Fallback to original if translation fails
    }
}

// Helper: Translate all tabs (requirements + procedures) to Filipino
async function translateTabs(tabs) {
    if (!tabs || !Array.isArray(tabs)) return [];

    const translatedTabs = [];
    for (const tab of tabs) {
        const translatedTab = { ...tab };

        // Translate tab name
        if (tab.tab_name) {
            translatedTab.tab_name_fil = await translateToFilipino(tab.tab_name);
        }

        // Translate requirements
        if (tab.requirements && Array.isArray(tab.requirements)) {
            translatedTab.requirements_fil = [];
            for (const req of tab.requirements) {
                translatedTab.requirements_fil.push({
                    requirement_name_fil: await translateToFilipino(req.requirement_name || ""),
                    secure_at_fil: await translateToFilipino(req.secure_at || ""),
                });
            }
        }

        // Translate procedures
        if (tab.procedures && Array.isArray(tab.procedures)) {
            translatedTab.procedures_fil = [];
            for (const proc of tab.procedures) {
                translatedTab.procedures_fil.push({
                    process_name_fil: await translateToFilipino(proc.process_name || ""),
                    process_description_fil: await translateToFilipino(proc.process_description || ""),
                    processing_time_fil: await translateToFilipino(proc.processing_time || ""),
                });
            }
        }

        translatedTabs.push(translatedTab);
    }
    return translatedTabs;
}

// Auto-translate when a service is created or updated
exports.translateService = onDocumentWritten(
    "offices/{officeId}/services/{serviceId}",
    async (event) => {
        const afterData = event.data.after.data();

        // Skip if document was deleted
        if (!afterData) return null;

        // Skip if already translated (prevent infinite loop)
        if (afterData._translated === true) return null;

        console.log(`Translating service: ${afterData.service_name || "unknown"}`);

        const updates = { _translated: true };

        // Translate service name
        if (afterData.service_name) {
            updates.service_name_fil = await translateToFilipino(afterData.service_name);
        }

        // Translate description
        if (afterData.description) {
            updates.description_fil = await translateToFilipino(afterData.description);
        }

        // Translate tabs (requirements + procedures)
        if (afterData.tabs) {
            updates.tabs_fil = await translateTabs(afterData.tabs);
        }

        // Write translations back to the same document
        return event.data.after.ref.update(updates);
    }
);

// One-time function: Trigger translation for all existing services
exports.translateExistingData = require("firebase-functions/v2/https").onRequest(
    { timeoutSeconds: 540, memory: "512MiB" },
    async (req, res) => {
    const db = admin.firestore();
    const officesSnap = await db.collection('offices').get();
    let count = 0;

    const officeCount = officesSnap.docs.length;
    console.log(`Found ${officeCount} offices`);

    for (const officeDoc of officesSnap.docs) {
        const officeData = officeDoc.data();
        console.log(`Office doc ID: ${officeDoc.id}, fields: ${Object.keys(officeData).join(', ')}`);

        if (officeData.office_name) {
            const officeNameFil = await translateToFilipino(officeData.office_name);
            await officeDoc.ref.update({ office_name_fil: officeNameFil, _translated: true });
            count++;
            console.log(`Translated office: ${officeData.office_name} -> ${officeNameFil}`);
        }

        const servicesSnap = await officeDoc.ref.collection('services').get();
        console.log(`Found ${servicesSnap.docs.length} services in ${officeDoc.id}`);

        for (const serviceDoc of servicesSnap.docs) {
            const serviceData = serviceDoc.data();

            const updates = { _translated: true };

            if (serviceData.service_name) {
                updates.service_name_fil = await translateToFilipino(serviceData.service_name);
            }
            if (serviceData.description) {
                updates.description_fil = await translateToFilipino(serviceData.description);
            }
            if (serviceData.tabs) {
                updates.tabs_fil = await translateTabs(serviceData.tabs);
            }

            await serviceDoc.ref.update(updates);
            count++;
            console.log(`Translated: ${serviceData.service_name}`);
        }
    }

    res.status(200).send(`Found ${officeCount} offices. Translated ${count} documents.`);
});

// Auto-translate when an office is created or updated
exports.translateOffice = onDocumentWritten(
    "offices/{officeId}",
    async (event) => {
        const afterData = event.data.after.data();

        if (!afterData) return null;
        if (afterData._translated === true) return null;

        console.log(`Translating office: ${afterData.office_name || "unknown"}`);

        const updates = { _translated: true };

        if (afterData.office_name) {
            updates.office_name_fil = await translateToFilipino(afterData.office_name);
        }

        return event.data.after.ref.update(updates);
    }
);
// Push notification: whenever a notification is added to a user's in-app list
// (users/{uid}/notifications/{notifId}), send it to every device that user is
// signed in on. Device tokens are saved by the app in users/{uid}.fcm_tokens.
exports.sendPushOnNotificationCreated = onDocumentCreated(
    "users/{uid}/notifications/{notifId}",
    async (event) => {
        const notif = event.data && event.data.data();
        if (!notif) return null;

        const { uid, notifId } = event.params;
        const userRef = admin.firestore().collection("users").doc(uid);
        const userSnap = await userRef.get();
        const tokens = (userSnap.exists && userSnap.get("fcm_tokens")) || [];
        if (tokens.length === 0) return null;

        const response = await admin.messaging().sendEachForMulticast({
            tokens,
            notification: {
                title: notif.title || "DocsEase Update", // same fallback as the in-app list
                body: notif.body || "",
            },
            // Data values must be strings; the app opens the notification by this id
            data: {
                notification_id: notifId,
                service_id: String(notif.service_id || ""),
            },
            android: { priority: "high" },
            apns: { payload: { aps: { sound: "default" } } },
        });

        // Drop tokens of uninstalled apps / signed-out devices
        const dead = [];
        response.responses.forEach((r, i) => {
            const code = r.error && r.error.code;
            if (code === "messaging/registration-token-not-registered" ||
                code === "messaging/invalid-registration-token") {
                dead.push(tokens[i]);
            }
        });
        if (dead.length > 0) {
            await userRef.update({ fcm_tokens: admin.firestore.FieldValue.arrayRemove(...dead) });
        }

        console.log(`Push for ${uid}/${notifId}: ${response.successCount} sent, ${dead.length} stale tokens removed`);
        return null;
    }
);
