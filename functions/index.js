/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest, onCall } = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin
const app = initializeApp();
const db = getFirestore();
const messaging = getMessaging();

/**
 * Trigger: When a new service request is created
 * Action: Notify admins and update statistics
 */
exports.onNewServiceRequest = onDocumentCreated("serviceRequests/{requestId}", async (event) => {
  try {
    const requestData = event.data.data();
    const requestId = event.params.requestId;
    
    logger.info(`New service request created: ${requestId}`, {
      category: requestData.category,
      service: requestData.service,
    });

    // Get admin users to notify
    const adminsSnapshot = await db.collection("admins").get();
    const adminTokens = [];
    
    // Collect admin FCM tokens
    for (const adminDoc of adminsSnapshot.docs) {
      const adminData = adminDoc.data();
      if (adminData.fcmToken) {
        adminTokens.push(adminData.fcmToken);
      }
    }
    
    // Send notification to admins if tokens exist
    if (adminTokens.length > 0) {
      await messaging.sendMulticast({
        tokens: adminTokens,
        notification: {
          title: "New Service Request",
          body: `${requestData.category} - ${requestData.service}`,
        },
        data: {
          requestId,
          click_action: "OPEN_SERVICE_REQUEST",
        },
      });
      
      logger.info(`Notifications sent to ${adminTokens.length} admins`);
    }
    
    // Update request statistics
    const statsRef = db.collection("statistics").doc("serviceRequests");
    await statsRef.set({
      totalRequests: (await statsRef.get()).data()?.totalRequests + 1 || 1,
      latestRequest: requestId,
      lastUpdated: new Date().toISOString(),
    }, { merge: true });
    
  } catch (error) {
    logger.error("Error processing new service request", error);
  }
});

/**
 * Trigger: When a service request is updated
 * Action: Notify the user about status changes
 */
exports.onServiceRequestUpdated = onDocumentUpdated("serviceRequests/{requestId}", async (event) => {
  try {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    const requestId = event.params.requestId;
    
    // Check if status has changed
    if (beforeData.status !== afterData.status) {
      logger.info(`Service request status changed: ${requestId}`, {
        oldStatus: beforeData.status,
        newStatus: afterData.status,
      });
      
      // Get user data
      const userId = afterData.userId;
      const userDoc = await db.collection("users").doc(userId).get();
      
      if (userDoc.exists) {
        const userData = userDoc.data();
        
        // If user has FCM token, send notification
        if (userData.fcmToken) {
          await messaging.send({
            token: userData.fcmToken,
            notification: {
              title: "Service Request Update",
              body: `Your request for ${afterData.service} is now ${afterData.status}`,
            },
            data: {
              requestId,
              status: afterData.status,
              click_action: "OPEN_SERVICE_REQUEST_DETAIL",
            },
          });
          
          logger.info(`Notification sent to user ${userId}`);
        }
        
        // Record status change in activity log
        await db.collection("serviceRequests").doc(requestId).collection("activityLog").add({
          timestamp: new Date().toISOString(),
          status: afterData.status,
          updatedBy: afterData.lastUpdatedBy || "system",
          notes: afterData.statusNotes || "",
        });
      }
    }
  } catch (error) {
    logger.error("Error processing service request update", error);
  }
});

/**
 * Callable function to assign a service request to a specific admin
 */
exports.assignServiceRequest = onCall({ enforceAppCheck: true }, async (request) => {
  try {
    const { requestId, adminId, adminName } = request.data;
    const callerUid = request.auth.uid;
    
    // Check if caller is an admin
    const callerAdminDoc = await db.collection("admins").doc(callerUid).get();
    if (!callerAdminDoc.exists) {
      throw new Error("Permission denied: Only admins can assign requests");
    }
    
    // Update the service request
    await db.collection("serviceRequests").doc(requestId).update({
      assignedTo: adminId,
      assignedToName: adminName,
      assignedAt: new Date().toISOString(),
      lastUpdatedBy: callerUid,
    });
    
    return { success: true, message: "Service request assigned successfully" };
  } catch (error) {
    logger.error("Error assigning service request", error);
    throw new Error(`Failed to assign service request: ${error.message}`);
  }
});

/**
 * API endpoint to get service request statistics for admin dashboard
 */
exports.getServiceRequestStats = onRequest({ cors: true }, async (req, res) => {
  try {
    // Check for admin authentication token
    const idToken = req.headers.authorization?.split("Bearer ")[1];
    if (!idToken) {
      return res.status(401).json({ error: "Unauthorized" });
    }
    
    // Authentication for API requests would normally validate the token
    // This is a simplified example
    const statsRef = db.collection("statistics").doc("serviceRequests");
    const statsDoc = await statsRef.get();
    
    if (!statsDoc.exists) {
      return res.status(200).json({ 
        totalRequests: 0,
        pendingRequests: 0,
        completedRequests: 0 
      });
    }
    
    // Get counts by status
    const pendingSnapshot = await db.collection("serviceRequests")
      .where("status", "==", "pending")
      .count()
      .get();
    
    const inProgressSnapshot = await db.collection("serviceRequests")
      .where("status", "==", "inProgress")
      .count()
      .get();
    
    const completedSnapshot = await db.collection("serviceRequests")
      .where("status", "==", "completed")
      .count()
      .get();
    
    const stats = statsDoc.data();
    return res.status(200).json({
      totalRequests: stats.totalRequests || 0,
      pendingRequests: pendingSnapshot.data().count || 0,
      inProgressRequests: inProgressSnapshot.data().count || 0,
      completedRequests: completedSnapshot.data().count || 0,
      lastUpdated: stats.lastUpdated
    });
  } catch (error) {
    logger.error("Error getting service request stats", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});
