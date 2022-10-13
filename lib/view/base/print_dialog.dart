import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/campaign_controller.dart';
import 'package:efood_multivendor_restaurant/controller/delivery_man_controller.dart';
import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/pos/pos_print_screen.dart';
import '../screens/pos/pos_wifprint_screen.dart';

class PrintDialog extends StatelessWidget {
  // final String icon;
  final String title;
  final String description;
  final Function onWifiPrinter;
  final Function onBluetooth;
  // final bool isLogOut;
  PrintDialog({this.title, @required this.description, @required this.onWifiPrinter,
    this.onBluetooth,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(width: 500, child: Padding(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child:  Icon(Icons.print),
            // child: Image.asset(icon, width: 50, height: 50),
          ),
          title != null ? Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
            child: Text(
              title, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Colors.red),
            ),
          ) : SizedBox(),

          Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child: Text(description, style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE), textAlign: TextAlign.center),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          GetBuilder<DeliveryManController>(builder: (dmController) {
            return GetBuilder<RestaurantController>(builder: (restController) {
              return GetBuilder<CampaignController>(builder: (campaignController) {
                return GetBuilder<AuthController>(builder: (authController) {
                    return GetBuilder<OrderController>(builder: (orderController) {
                      return (authController.isLoading || orderController.isLoading || campaignController.isLoading || restController.isLoading
                      || dmController.isLoading) ? Center(child: CircularProgressIndicator()) : Row(children: [

                        Expanded(child: TextButton(
                          onPressed: () {
                            Get.back();
                            Get.to(()=>PosWifiPrintScreen());
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: Size(1170, 40), padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                          ),
                          child: Text(
                            'Wifi Printer'.tr , textAlign: TextAlign.center,
                            style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyText1.color),
                          ),
                        )),
                        SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

                        Expanded(child: CustomButton(
                          buttonText: 'Bluetooth Printer'.tr,
                          onPressed: () {
                            Get.back();
                            Get.to(()=>PosPrintScreen());
                          },
                          height: 40,
                        )),

                      ]);
                    });
                  }
                );
              });
            });
          }),

        ]),
      )),
    );
  }
}