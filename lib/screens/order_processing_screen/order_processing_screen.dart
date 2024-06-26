import 'package:ecommerce_app/blocs/order_processing_bloc/order_processing_bloc.dart';
import 'package:ecommerce_app/blocs/place_order_bloc/place_order_bloc.dart';
import 'package:ecommerce_app/blocs/user_bloc/user_bloc.dart';
import 'package:ecommerce_app/common_widgets/my_button.dart';
import 'package:ecommerce_app/common_widgets/my_outlined_button.dart';
import 'package:ecommerce_app/constants/app_assets.dart';
import 'package:ecommerce_app/constants/app_colors.dart';
import 'package:ecommerce_app/constants/app_dimensions.dart';
import 'package:ecommerce_app/models/order.dart';
import 'package:ecommerce_app/models/order_status.dart';
import 'package:ecommerce_app/models/order_summary.dart';
import 'package:ecommerce_app/router/arguments/arguments.dart';
import 'package:ecommerce_app/screens/order_tracking_screen/order_tracking_screen.dart';
import 'package:ecommerce_app/utils/order_util.dart';
import 'package:ecommerce_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({
    super.key,
  });

  static const String routeName = "/order-processing-screen";

  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _placeOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrderProcessingBloc, OrderProcessingState>(
          listener: (_, state) {
            if (state is OrderProcessingSuccessfully) {
              context.read<UserBloc>().add(ReloadUser());
              // TODO: Clear cart
              // TODO: Reset PlaceOrderState
            }
          },
          builder: (context, state) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // Icon section
                  if (state is OrderProcessingSuccessfully) Lottie.asset(AppAssets.lottieSuccess, height: 300, width: 300),
                  if (state is OrderProcessingFailed) Lottie.asset(AppAssets.lottieFail, height: 300, width: 300),
                  if (state is OrderProcessingAdding) Lottie.asset(AppAssets.lottieWaiting, height: 300, width: 300),
                  const SizedBox(height: 20),

                  // Description section
                  if (state is OrderProcessingSuccessfully) Text("Order successfully", style: Theme.of(context).textTheme.displaySmall),
                  if (state is OrderProcessingFailed)
                    Text(
                        // "Order failed. Please try again."
                        state.message,
                        style: Theme.of(context).textTheme.displaySmall),
                  if (state is OrderProcessingAdding) Text("Waiting...", style: Theme.of(context).textTheme.displayMedium),
                  const Spacer(),

                  // Actions section
                  if (state is OrderProcessingSuccessfully)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: MyOutlinedButton(
                                onPressed: () => _navigateToOrderTrackingScreen(state.order),
                                child: Row(
                                  children: [
                                    Text("View order", style: Theme.of(context).textTheme.labelMedium),
                                  ],
                                )),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MyButton(
                              onPressed: () {
                                Navigator.popUntil(context, (route) => route.isFirst);
                              },
                              borderRadius: 12,
                              child: Text(
                                "Home",
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                      color: AppColors.whiteColor,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (state is OrderProcessingFailed)
                    MyOutlinedButton(
                        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding),
                        onPressed: _onFailBackButton,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Back", style: Theme.of(context).textTheme.labelLarge),
                          ],
                        )),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _placeOrder() async {
    final placeOrderState = context.read<PlaceOrderBloc>().state;
    final userState = context.read<UserBloc>().state;
    if (userState.status == UserStatus.loaded) {
      final user = userState.user;
      if (user!.id == null) {
        Utils.showSnackBar(context: context, message: "Something went wrong. Please try again.");
        return;
      }

      final OrderModel order = OrderModel(
          id: "",
          orderNumber: OrderUtil().generateOrderNumber(user.id!),
          customerId: user.id!,
          customerName: user.name ?? "",
          customerPhoneNumber: placeOrderState.address!.phoneNumber,
          address: placeOrderState.address!,
          orderSummary: OrderSummary(
            amount: placeOrderState.amount!,
            shipping: placeOrderState.shipping!,
            promotionDiscount: placeOrderState.promoDiscount!,
            total: placeOrderState.totalPrice!,
          ),
          isCompleted: false,
          paymentMethod: placeOrderState.paymentMethod!.code,
          isPaid: placeOrderState.paymentMethod!.code == "cash_on_delivery" ? false : true,
          currentOrderStatus: OrderStatus.pending,
          createdAt: DateTime.now());

      context.read<OrderProcessingBloc>().add(
            AddOrder(
              order: order,
              items: placeOrderState.cart!.cartItems,
              cartItems: placeOrderState.cart?.cartItems ?? [],
              cardNumber: placeOrderState.paymentInformation?.cardNumber ?? "",
              promotion: placeOrderState.promotion,
            ),
          );
    } else {
      Utils.showSnackBar(context: context, message: "Something went wrong. Please try again.");
    }
  }

  _onFailBackButton() {
    Navigator.pop(context);
    context.read<OrderProcessingBloc>().add(ResetOrderProcessingState());
  }

  _navigateToOrderTrackingScreen(OrderModel order) {
    Navigator.pushNamed(context, OrderTrackingScreen.routeName,
        // TODO: Pass orderItems
        arguments: OrderTrackingScreenArgs(order: order, orderItems: []));
  }
}
