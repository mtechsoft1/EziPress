import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTypeButton extends StatefulWidget {
  final String title;
  final int index;
  final OrderController orderController;
  final bool fromHistory;
  OrderTypeButton({@required this.title, @required this.index, @required this.orderController, @required this.fromHistory});

  @override
  State<OrderTypeButton> createState() => _OrderTypeButtonState();
}

class _OrderTypeButtonState extends State<OrderTypeButton> {
  @override
  Widget build(BuildContext context) {
    int _selectedIndex;
    int _length = 0;
    int _titleLength = 0;
    bool isSelected = _selectedIndex == widget.index;
    return Obx(() {
      return InkWell(
        onTap: () async {
          print("==title:${widget.title}==index:${widget.index}=======");
          isSelected=true;
          setState(() {

          });
          // update();
          // update();
        },
        // onTap: () => fromHistory ? orderController.setHistoryIndex(index) : orderController.setOrderIndex(index),
        child: Row(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.title}${widget.fromHistory ? '' : ' ($_length)'}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                color: isSelected ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyText1.color,
              ),
            ),
          ),

          // (index != _titleLength-1 && index != _selectedIndex && index != _selectedIndex-1) ? Container(
          //   height: 15, width: 1, color: Theme.of(context).disabledColor,
          // ) : SizedBox(),

        ]),
      );
    });
  }
  void update(){
    update();
  }
}
