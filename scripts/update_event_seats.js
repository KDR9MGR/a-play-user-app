const admin = require('firebase-admin');
const path = require('path');
const serviceAccount = require(path.join(__dirname, '..', 'service-account-key.json'));

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Seating configuration
const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
const columnsPerRow = 14;
const vipRows = rows.slice(0, 3); // First 3 rows are VIP

async function updateEventSeats() {
  try {
    // Get all events
    const eventsSnapshot = await db.collection('events').get();
    
    console.log(`Found ${eventsSnapshot.size} events to update`);

    for (const eventDoc of eventsSnapshot.docs) {
      console.log(`Updating seats for event: ${eventDoc.id}`);
      
      // Create a batch write
      let batch = db.batch();
      let operationCount = 0;
      
      // Generate seats for each row and column
      for (const row of rows) {
        for (let col = 1; col <= columnsPerRow; col++) {
          const seatId = `${row}_${col}`;
          const isVIP = vipRows.includes(row);
          
          const seatRef = db
            .collection('events')
            .doc(eventDoc.id)
            .collection('seats')
            .doc(seatId);
          
          const seatData = {
            row: row,
            col: col,
            status: 'available',
            type: isVIP ? 'VIP' : 'Regular',
            price: isVIP ? 200.0 : 100.0,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          };
          
          batch.set(seatRef, seatData, { merge: true });
          operationCount++;
          
          // Firebase has a limit of 500 operations per batch
          if (operationCount === 499) {
            await batch.commit();
            batch = db.batch();
            operationCount = 0;
            console.log(`Committed batch for event ${eventDoc.id}`);
          }
        }
      }
      
      // Commit any remaining operations
      if (operationCount > 0) {
        await batch.commit();
        console.log(`Committed final batch for event ${eventDoc.id}`);
      }
      
      console.log(`Successfully updated seats for event: ${eventDoc.id}`);
    }
    
    console.log('Successfully updated all events with new seating layout');
    process.exit(0);
  } catch (error) {
    console.error('Error updating event seats:', error);
    process.exit(1);
  }
}

// Run the update
updateEventSeats(); 