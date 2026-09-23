import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_gateway.dart';
import 'notification_service.dart';

final notificationGatewayProvider = Provider<NotificationGateway>(
  (_) => NotificationService.instance,
);
