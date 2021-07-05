part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class setUpNotification extends NotificationEvent{

}

class checkStatusNotification extends NotificationEvent{

}