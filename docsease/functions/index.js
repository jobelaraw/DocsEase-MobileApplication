const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
admin.initializeApp();

// Modern v2 onCall syntax
exports.resetUserPassword = onCall(async (request) => {
    // 1. Log exactly what Flutter sends us so we can see it in Google Cloud!
    console.log("Incoming request data:", request.data);

    // v2, the payload is stored inside 'request.data'
    const email = request.data.email;
    const enteredCode = request.data.otp;
    const newPassword = request.data.newPassword;

    // THE SAFETY NET: Check if the email is blank before searching the database!
    if (!email || email.trim() === "") {
        throw new HttpsError('invalid-argument', 'Backend received a blank email! The app lost the email variable in memory.');
    }

    // Double check the OTP securely on the server
    const docRef = admin.firestore().collection('recovery_codes').doc(email);
    const docSnap = await docRef.get();

    if (!docSnap.exists || docSnap.data().code !== enteredCode) {
        throw new HttpsError('permission-denied', 'Invalid or expired OTP code.');
    }

    // Look up the user and change their password
    const userRecord = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(userRecord.uid, {
        password: newPassword
    });

    // Delete the OTP
    await docRef.delete();

    return { success: true };
});