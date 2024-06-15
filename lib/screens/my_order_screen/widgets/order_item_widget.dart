import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:ecommerce_app/blocs/blocs.dart';
import 'package:ecommerce_app/common_widgets/common_widgets.dart';
import 'package:ecommerce_app/constants/constants.dart';
import 'package:ecommerce_app/extensions/extensions.dart';
import 'package:ecommerce_app/models/models.dart';
import 'package:ecommerce_app/repositories/cart_repository.dart';
import 'package:ecommerce_app/repositories/review_repository.dart';
import 'package:ecommerce_app/screens/my_order_screen/widgets/widgets.dart';
import 'package:ecommerce_app/utils/utils.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderProductDetail orderItem;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final bool isComplete;

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.orderItem,
    this.margin = const EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding, vertical: 10),
    this.onTap,
    this.isComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      child: PrimaryBackground(
        margin: margin,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: orderItem.productImgUrl ?? "",
                height: size.width * 0.21,
                width: size.width * 0.21,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (orderItem.productName != null)
                    Text(
                      orderItem.productName!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.labelMedium,
                    ),
                  if (orderItem.productBrand != null && orderItem.productBrand!.isNotEmpty)
                    Text(
                      orderItem.productBrand!,
                      style: AppStyles.bodyLarge,
                    ),
                  Text(
                    "${AppLocalizations.of(context)!.quantity}: ${orderItem.quantity}",
                    style: AppStyles.bodyMedium,
                  ),
                  Text(
                    "${AppLocalizations.of(context)!.size}: ${orderItem.size}",
                    style: AppStyles.bodyMedium,
                  ),
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.color}: ",
                        style: AppStyles.bodyMedium,
                      ),
                      if (orderItem.color != null) ColorDotWidget(color: orderItem.color!.toColor())
                    ],
                  ),
                ],
              ),
            ),
            // const Spacer(),
            Column(
              children: [
                Text(
                  order.currentOrderStatus.toOrderStatusLabel(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (orderItem.productPrice != null)
                  Text(
                    orderItem.productPrice!.toPriceString(),
                    style: AppStyles.headlineLarge,
                  ),
                if (isComplete && orderItem.review == null)
                  MyButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      onPressed: () => _onWriteReview(context),
                      child: Text(AppLocalizations.of(context)!.review,
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.whiteColor,
                          ))),
                if (isComplete && orderItem.review != null)
                  MyButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      onPressed: () => _onAddToCart(context),
                      child: Text(AppLocalizations.of(context)!.buyAgain,
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.whiteColor,
                          ))),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onWriteReview(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) {
          return WriteReviewBottomSheet(
            orderItem: orderItem,
            onAddReview: (rating, content) async {
              await ReviewRepository().addReview(
                  context: context,
                  orderId: order.id,
                  orderItemId: orderItem.id ?? "",
                  productId: orderItem.productId ?? "",
                  rating: rating,
                  content: content ?? "");
            },
          );
        });
  }

  void _onAddToCart(BuildContext context) async {
    CartRepository()
        .addCartItem(
      productId: orderItem.productId ?? "",
      size: orderItem.size ?? "",
      color: orderItem.color ?? "",
      quantity: 1,
    )
        .then((value) {
      context.read<CartBloc>().add(LoadCart());
      _showNotification(context);
    });
  }

  void _showNotification(BuildContext context) {
    Utils.showSnackBarSuccess(
      context: context,
      message: "The product has been added to cart.",
      title: "Success",
    );
  }
}
