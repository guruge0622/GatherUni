/**
 * Example Node script showing how to perform transactional bookings
 * using the Firebase Admin SDK. This is intended as a server-side example
 * (for Cloud Functions or a trusted backend). Set `GOOGLE_APPLICATION_CREDENTIALS`
 * to a service account JSON before running.
 *
 * Usage: node scripts/booking_transaction_example.js <eventId> <userId>
 */

const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function createBooking(eventId, userId, meta = {}) {
  const eventRef = db.collection('events').doc(eventId);
  const bookingRef = eventRef.collection('bookings').doc();

  await db.runTransaction(async (tx) => {
    const eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) throw new Error('Event not found');
    const current = eventSnap.get('bookings') || 0;

    tx.set(bookingRef, {
      userId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      ...meta,
    });

    tx.update(eventRef, { bookings: current + 1 });
  });

  return bookingRef.id;
}

async function cancelBooking(eventId, bookingId, userId) {
  const eventRef = db.collection('events').doc(eventId);
  const bookingRef = eventRef.collection('bookings').doc(bookingId);

  await db.runTransaction(async (tx) => {
    const bookingSnap = await tx.get(bookingRef);
    if (!bookingSnap.exists) throw new Error('Booking not found');
    const booking = bookingSnap.data();
    const bookingOwner = booking.userId;

    const eventSnap = await tx.get(eventRef);
    if (!eventSnap.exists) throw new Error('Event not found');
    const organizerId = eventSnap.get('organizerId');

    const allowed = bookingOwner === userId || organizerId === userId;
    if (!allowed) throw new Error('Not authorized to cancel booking');

    tx.delete(bookingRef);
    const current = eventSnap.get('bookings') || 0;
    tx.update(eventRef, { bookings: Math.max(0, current - 1) });
  });
}

// CLI runner
if (require.main === module) {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    console.error('Usage: node booking_transaction_example.js <eventId> <userId>');
    process.exit(1);
  }
  const [eventId, userId] = args;
  createBooking(eventId, userId)
    .then((id) => console.log('Created booking', id))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}
