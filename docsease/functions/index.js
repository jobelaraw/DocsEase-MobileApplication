const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { Translate } = require("@google-cloud/translate").v2;

admin.initializeApp();
const translate = new Translate();

// Existing: Reset user password
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
