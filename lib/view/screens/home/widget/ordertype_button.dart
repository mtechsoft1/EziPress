import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:flutter/material.dart';

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
    if(widget.fromHistory) {
      _selectedIndex = widget.orderController.historyIndex;
      _titleLength = widget.orderController.statusList.length;
      _length = 0;
    }else {
      _selectedIndex = widget.orderController.orderIndex;
      _titleLength = widget.orderController.runningOrders.length;
      _length = widget.orderController.runningOrders[widget.index].orderList.length;
    }
    bool isSelected = _selectedIndex == widget.index;
    return InkWell(
      onTap: () => widget.fromHistory ? widget.orderController.setHistoryIndex(widget.index) : widget.orderController.setOrderIndex(widget.index),
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
  }
}
