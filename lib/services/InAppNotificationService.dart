import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fostr/core/constants.dart';
import 'package:fostr/services/NotificationApiService.dart';

class NotificationPayload {
  NotificationType type;
  List<String> tokens;
  Map<String, dynamic> data;
  NotificationPayload(
      {required this.type, required this.tokens, required this.data});
}

class InAppNotificationService {
  final NotificationApiService _notificationApiService =
      NotificationApiService();

  Future<void> sendNotification(NotificationPayload payload) async {
    switch (payload.type) {
      case NotificationType.Follow:
        await _sendFollowNotification(payload);
        break;

      case NotificationType.Invite:
        await _sendRoomInviteNotification(payload);
        break;

      case NotificationType.Event:
        await _sendEventNotification(payload);
        break;

      case NotificationType.Bookmarked:
        await _sendLikeNotification(payload);
        break;

      case NotificationType.Comment:
        await _sendCommentNotification(payload);
        break;

      case NotificationType.Review:
        await _sendReviewNotification(payload);
        break;

      case NotificationType.Rating:
        await _sendRatingNotification(payload);
        break;

      case NotificationType.BookclubInvitationRequest:
        await _sendBookclubInvitationRequestNotification(payload);
        break;

      case NotificationType.BookclubInvitationAccepted:
        await _sendBookclubInvitationAcceptedNotification(payload);
        break;

      default:
        throw Exception("Notification type not supported");
    }
  }

  Future<void> _sendFollowNotification(NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "0",
      "userId": payload.data["senderUserId"],
      "userName": payload.data["senderUserName"],
      "currentToken": payload.data["senderToken"],
      "authToken": payload.data["authToken"],
      "followedUserId": payload.data["recipientUserId"],
      "followedUserName": payload.data["recipientUserName"],
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendRoomInviteNotification(NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "1",
      "userId": payload.data["senderUserId"],
      "recipientUserId": payload.data["recipientUserId"],
      "userName": payload.data["senderUserName"],
      "authToken": payload.data["authToken"],
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendLikeNotification(NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "2",
      "recipientUserId": payload.data["recipientUserId"],
      "userId": payload.data["senderUserId"],
      "userName": payload.data["senderUserName"],
      "authToken": payload.data["authToken"],
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendEventNotification(NotificationPayload payload) async {
    // await _notificationApiService.sendNotification({
    //   "tokens": payload.tokens,
    //   "notificationId": "3",
    //   "userId": payload.data["senderUserId"],
    //   "userName": payload.data["senderUserName"],
    //   "authToken": payload.data["authToken"],
    //   "message": payload.data["message"],
    // });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendCommentNotification(NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "4",
      "recipientUserId": payload.data["recipientUserId"],
      "userId": payload.data["senderUserId"],
      "userName": payload.data["senderUserName"],
      "authToken": payload.data["authToken"],
      "message": payload.data["message"],
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendReviewNotification(NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "5",
      "recipientUserId": payload.data["recipientUserId"],
      "userId": payload.data["senderUserId"],
      "userName": payload.data["senderUserName"],
      "authToken": payload.data["authToken"],
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendRatingNotification(NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "6",
      "recipientUserId": payload.data["recipientUserId"],
      "userId": payload.data["senderUserId"],
      "userName": payload.data["senderUserName"],
      "authToken": payload.data["authToken"],
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendBookclubInvitationRequestNotification(
      NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "7",
      "recipientUserId": payload.data["recipientUserId"],
      "userId": payload.data["senderUserId"],
      "userName": payload.data["senderUserName"],
      "authToken": payload.data["authToken"],
      "bookclubId": payload.data["bookclubId"],
      "bookclubName": payload.data["bookclubName"],
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendBookclubInvitationAcceptedNotification(
      NotificationPayload payload) async {
    await _notificationApiService.sendNotification({
      "tokens": payload.tokens,
      "notificationId": "8",
      "recipientUserId": payload.data["recipientUserId"],
      "userId": payload.data["senderUserId"],
      "userName": payload.data["senderUserName"],
      "authToken": payload.data["authToken"],
      "title": payload.data["title"]
    });
    await _sendInAppNotification(payload);
  }

  Future<void> _sendInAppNotification(NotificationPayload payload) async {
    final _db = FirebaseFirestore.instance
        .collection("users")
        .doc(payload.data["recipientUserId"]);
    _db.update({"unreadNotifications": true});
    await _db.collection("notifications").add({
      "type": payload.type.name,
      "senderUserId": payload.data["senderUserId"],
      "title": payload.data["title"],
      "body": payload.data["body"],
      "payload": payload.data["payload"],
      "dateTime": DateTime.now().toUtc(),
      "read": false,
    });
  }

  Future<String?> getNotificationToken(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    final token =
        doc.data()?["deviceToken"] ?? doc.data()?["notificationToken"] ?? null;
    return token;
  }
}
