import 'package:ecommerce_app/models/order_status.dart';

extension OrderStatusExt on OrderStatus {
  String toOrderStatusString() {
    return orderStatusToString[this] ?? orderStatusToString[OrderStatus.pending]!;
  }

  String toOrderStatusLabel() {
    return orderStatusToLabel[this] ?? orderStatusToLabel[OrderStatus.pending]!;
  }
}
