const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createPaymentIntent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login required");
  }

  const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
  const { eventId, amountInCents, currency } = request.data;

  const paymentIntent = await stripe.paymentIntents.create({
    amount: amountInCents,
    currency: currency ?? "myr",
    metadata: {
      eventId,
      userId: request.auth.uid,
    },
  });

  return { clientSecret: paymentIntent.client_secret };
});
