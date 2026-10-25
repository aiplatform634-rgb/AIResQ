const { initializeApp, cert } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount),
});

async function makeOwner() {
  const email = "aiplatform634@gmail.com";

  try {
    const auth = getAuth();

    const user = await auth.getUserByEmail(email);

    const existingClaims = user.customClaims || {};

    await auth.setCustomUserClaims(user.uid, {
      ...existingClaims,
      admin: true,
      role: "owner",
    });

    console.log("=================================");
    console.log("OWNER ROLE ASSIGNED SUCCESSFULLY");
    console.log("Email:", email);
    console.log("Role: OWNER");
    console.log("=================================");
  } catch (error) {
    console.error("ERROR:", error.message);
  }
}

makeOwner();