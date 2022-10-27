import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/notification_controller.dart';
import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_model.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor_restaurant/view/base/order_shimmer.dart';
import 'package:efood_multivendor_restaurant/view/base/order_widget.dart';
import 'package:efood_multivendor_restaurant/view/screens/home/widget/order_button.dart';
import 'package:efood_multivendor_restaurant/view/screens/home/widget/ordertype_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class HomeScreen extends StatelessWidget {



  Future<void> _loadData() async {
    await Get.find<AuthController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();

  }
RxInt tabIndex=0.obs;
  RxBool isSelect=false.obs;
  @override
  Widget build(BuildContext context) {
    _loadData();
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: Image.asset(Images.logo, height: 30, width: 30),
        ),
        titleSpacing: 0, elevation: 0,
        /*title: Text(AppConstants.APP_NAME, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(
          color: Theme.of(context).textTheme.bodyText1.color, fontSize: Dimensions.FONT_SIZE_DEFAULT,
        )),*/
        title: Image.asset(Images.logo_name, width: 120),
        actions: [IconButton(
          icon: GetBuilder<NotificationController>(builder: (notificationController) {
            bool _hasNewNotification = false;
            if(notificationController.notificationList != null) {
              _hasNewNotification = notificationController.notificationList.length
                  != notificationController.getSeenNotificationCount();
            }
            return Stack(children: [
              Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyText1.color),
              _hasNewNotification ? Positioned(top: 0, right: 0, child: Container(
                height: 10, width: 10, decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                border: Border.all(width: 1, color: Theme.of(context).cardColor),
              ),
              )) : SizedBox(),
            ]);
          }),
          onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
        )],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(children: [

            GetBuilder<AuthController>(builder: (authController) {
              return Column(children: [
                Container(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 200], spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: Row(children: [
                    Expanded(child: Text(
                      'restaurant_temporarily_closed'.tr, style: robotoMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    )),
                    authController.profileModel != null ? Switch(
                      value: !authController.profileModel.restaurants[0].active,
                      activeColor: Theme.of(context).primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (bool isActive) {
                        Get.dialog(ConfirmationDialog(
                          icon: Images.warning,
                          description: isActive ? 'are_you_sure_to_close_restaurant'.tr : 'are_you_sure_to_open_restaurant'.tr,
                          onYesPressed: () {
                            Get.back();
                            authController.toggleRestaurantClosedStatus();
                          },
                        ));
                      },
                    ) : Shimmer(duration: Duration(seconds: 2), child: Container(height: 30, width: 50, color: Colors.grey[300])),
                  ]),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                Container(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.asset(Images.wallet, width: 60, height: 60),
                      SizedBox(width: Dimensions.PADDING_SIZE_LARGE),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'today'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Text(
                          authController.profileModel != null ? PriceConverter.convertPrice(authController.profileModel.todaysEarning) : '0',
                          style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                        ),
                      ]),
                    ]),
                    SizedBox(height: 30),
                    Row(children: [
                      Expanded(child: Column(children: [
                        Text(
                          'this_week'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Text(
                          authController.profileModel != null ? PriceConverter.convertPrice(authController.profileModel.thisWeekEarning) : '0',
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).cardColor),
                        ),
                      ])),
                      Container(height: 30, width: 1, color: Theme.of(context).cardColor),
                      Expanded(child: Column(children: [
                        Text(
                          'this_month'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Text(
                          authController.profileModel != null ? PriceConverter.convertPrice(authController.profileModel.thisMonthEarning) : '0',
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).cardColor),
                        ),
                      ])),
                    ]),
                  ]),
                ),
              ]);
            }),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            GetBuilder<OrderController>(builder: (orderController) {
              List<OrderModel> _orderList = [];
              List<OrderModel> _dineInOderList = [];
              var dineIn;
              if(orderController.runningOrders != null) {
                _orderList = orderController.runningOrders[orderController.orderIndex].orderList;
                print("==length:${_orderList.length}========");
                // if()
              }

              print("==dineIn:$dineIn=====");
              return Column(children: [
                // Text("data"),
                orderController.runningOrders != null ? Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, i) {
                        List nameList=['Delivery','DineIn','Reservation'];
                        return  Obx((){
                          return InkWell(
                            onTap: (){
                              tabIndex.value=i;
                              isSelect.value=true;

                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                // color:  Theme.of(context).cardColor,
                                color: (tabIndex.value==i)? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${nameList[i]}',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                                  // color: Theme.of(context).textTheme.bodyText1.color,
                                  color:(tabIndex.value==i)?Theme.of(context).cardColor : Theme.of(context).textTheme.bodyText1.color,
                                ),
                              ),
                            ),
                          );
                        });
                        //   OrderTypeButton(
                        //   title: nameList[i], index: i,
                        //   orderController: orderController, fromHistory: false,
                        // );
                      },
                    )
                ) : SizedBox(),
                SizedBox(height: Dimensions.FONT_SIZE_DEFAULT,),
                Obx((){
                  if(tabIndex.value==0&&orderController.runningOrders != null){
                    return Column(
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: orderController.runningOrders.length,
                            itemBuilder: (context, index) {
                              return OrderButton(
                                title: orderController.runningOrders[index].status.tr, index: index,
                                orderController: orderController, fromHistory: false,
                              );
                            },
                          ),
                        ),
                        orderController.runningOrders != null ? InkWell(
                          onTap: () => orderController.toggleCampaignOnly(),
                          child: Row(children: [
                            Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              value: orderController.campaignOnly,
                              onChanged: (isActive) => orderController.toggleCampaignOnly(),
                            ),
                            Text(
                              'campaign_order'.tr,
                              style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                            ),
                          ]),
                        ) : SizedBox(),
                      ],
                    ) ;
                  }else{
                    return  SizedBox();
                  }
                }),

                Obx(() {
                  if( tabIndex.value==0){
                    return orderController.runningOrders != null ? _orderList.length > 0 ?
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _orderList.length,
                      itemBuilder: (context, index) {
                        // int dineIn;
                        if(_orderList[index].orderType!="reservation"&&_orderList[index].orderType!="dinin")
                        return
                          OrderWidget(orderModel: _orderList[index], hasDivider: index != _orderList.length-1, isRunning: true);
                      },
                    ) : Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(child: Text('no_order_found'.tr)),
                    ) : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return OrderShimmer(isEnabled: orderController.runningOrders == null);
                      },
                    );
                  }else if(tabIndex.value==1){
                    return Container(child: Text("DineIn"));
                  }else{
                    return Container(child: Text("Reservation"));
                  }

                }),



              ]);
            }),

            // Obx(() {
            //   return ;
            // })
          ]),
        ),
      ),

    );
  }
}
