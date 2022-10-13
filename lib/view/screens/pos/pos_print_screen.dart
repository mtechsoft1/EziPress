import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../controller/order_controller.dart';
import '../../../data/model/response/order_details_model.dart';
import '../../../data/model/response/order_model.dart';
import '../../../data/model/response/product_model.dart';
import '../../../helper/price_converter.dart';
import '../../base/custom_snackbar.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';

class PosPrintScreen extends StatefulWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  PosPrintScreen({@required this.order, @required this.orderDetails});
  @override
  _PosPrintScreenState createState() => _PosPrintScreenState();
}

OrderController orderController = Get.put(OrderController());
Rx<ProductModel> productModel = ProductModel().obs;

class _PosPrintScreenState extends State<PosPrintScreen> {
  final box = GetStorage();
  double _deliveryCharge = 0;
  double _itemsPrice = 0;
  double _discount = 0;
  double _couponDiscount = 0;
  double _dmTips = 0;
  double _tax = 0;
  double _addOns = 0;
  double subTotal = 0;
  double total = 0;
  OrderModel _order = orderController.orderModel;
  String name = "";
  String adress = "";
  String phone = "";

  int n=1;
  @override
  void initState()  {
    print("=======THIS IS init screen=====_order:${_order.id}======");
    var mac = box.read(AppConstants.Bluetooth_Device);
    if (mac != null) {
      setConnect(mac);
      print("mac=========$mac=========");
    }
    checkConection();
    // String isConnected = await BluetoothThermalPrinter.connectionStatus;

    name = "${orderController.orderModel?.restaurantName}";
    adress = "${orderController.orderModel?.restaurantAddress}";
    phone = "${orderController.orderModel?.restaurantPhone}";
    if (orderController.orderDetailsModel != null) {
      if (_order.orderType == 'delivery') {
        _deliveryCharge = _order.deliveryCharge;
        _dmTips = _order.dmTips;
      }
      _discount = _order.restaurantDiscountAmount;
      _tax = _order.totalTaxAmount;
      _couponDiscount = _order.couponDiscountAmount;
      for (OrderDetailsModel orderDetails
          in orderController.orderDetailsModel) {
        for (AddOn addOn in orderDetails.addOns) {
          _addOns = _addOns + (addOn.price * addOn.quantity);
        }
        _itemsPrice =
            _itemsPrice + (orderDetails.price * orderDetails.quantity);
      }
    }
    subTotal = _itemsPrice + _addOns;
    total = _itemsPrice +
        _addOns -
        _discount +
        _tax +
        _deliveryCharge -
        _couponDiscount +
        _dmTips;
    super.initState();
  }

  RxBool connected = false.obs;
  List availableBluetoothDevices = [];
  Future<void> checkConection() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      connected.value=true;
    } else {
      showCustomSnackBar("Printer is not connected");
    }
  }
  Future<void> getBluetooth() async {
    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths;
    });
  }

  Future<void> setConnect(String mac) async {
    print("=======name:$mac===============");
    final String result = await BluetoothThermalPrinter.connect(mac);
    print("state connected $result");
    print("state connected $mac");
    if (result == "true") {
      isNewSearch.value = false;
      // setState(() {
      connected.value = true;
      // });
      box.write(AppConstants.USER_PASSWORD, "$mac");
    }
  }

  Future<void> printTicket() async {
    if(connected.value){
      List<int> bytes = await getTicket();
      print("======bytes===$bytes==");
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    }else{
      String isConnected = await BluetoothThermalPrinter.connectionStatus;
      if (isConnected == "true") {
        List<int> bytes = await getTicket();
        print("======bytes===$bytes==");
        final result = await BluetoothThermalPrinter.writeBytes(bytes);
        print("Print $result");
      } else {
        showCustomSnackBar("Printer is not connected");
      }
    }
  }
  Future<void> printGraphics() async {
    if(connected.value){
      List<int> bytes = await getGraphicsTicket();
      print("======bytes===$bytes==");
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    }else{
      String isConnected = await BluetoothThermalPrinter.connectionStatus;
      if (isConnected == "true") {
        List<int> bytes = await getGraphicsTicket();
        print("======bytes===$bytes==");
        final result = await BluetoothThermalPrinter.writeBytes(bytes);
        print("Print $result");
      } else {
        //Hadnle Not Connected Senario
      }
    }

  }

  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    bytes += generator.qrcode('example.com');

    bytes += generator.hr();

    // Print Barcode using native function
    final List<int> barData = [n, 2, 3, 4, 5, 6, 7, 8, 9, 0, n];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.text("$name", styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2,), linesAfter: 1);
    bytes += generator.text("#${_order.id}", styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2,),);
    bytes += generator.text("$adress", styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('$phone', styles: PosStyles(align: PosAlign.center));
    bytes += generator.text("${DateTime.now()}", styles: PosStyles(align: PosAlign.center),);
    bytes += generator.hr();
    bytes += generator.text("Customer:", styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1,));
    bytes += generator.text("${_order.customer.fName} ${_order.customer.lName}", styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1,));
    bytes += generator.text("${_order.customer.phone}", styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1,),linesAfter: 1);
    bytes += generator.text("Address:", styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1,));
    bytes += generator.text("${_order.deliveryAddress.address}", styles: PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1,));
    bytes += generator.hr();
    bytes += generator.row([
            PosColumn(
                text: 'No',
                width: 1,
                styles: PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(
                text: 'Item',
                width: 5,
                styles: PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(
                text: 'Price',
                width: 2,
                styles: PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(
                text: 'Qty',
                width: 2,
                styles: PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(
                text: 'Total',
                width: 2,
                styles: PosStyles(align: PosAlign.right, bold: true)),
       ]);
    for(int i=0; i<orderController.orderDetailsModel.length; i++){
      bytes += generator.row([
        PosColumn(
            text: '$i',
            width: 1,
            styles: PosStyles(align: PosAlign.left, )),
        PosColumn(
            text: '${orderController.orderDetailsModel[i].foodDetails.name}',
            width: 5,
            styles: PosStyles(align: PosAlign.left,)),
        PosColumn(
            text: '${orderController.orderDetailsModel[i].foodDetails.price}',
            width: 2,
            styles: PosStyles(align: PosAlign.center,)),
        PosColumn(
            text: '${orderController.orderDetailsModel[i].quantity}',
            width: 2,
            styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '${(orderController.orderDetailsModel[i].price)*(orderController.orderDetailsModel[i].quantity)}',
            width: 2,
            styles: PosStyles(align: PosAlign.right,)),
      ]);


    }
    bytes += generator.hr();
    bytes += generator.row([
      // PosColumn(text: "1", width: 1),
      PosColumn(
          text: "Subtotal",
          width: 10,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(text:"${PriceConverter.convertPrice(subTotal)}", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "Discount", width: 9),
      PosColumn(
          text: "(-)$_discount",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "Delivery Man Tips",
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "(+)$_dmTips",
          width: 3,
          styles: PosStyles(
            align: PosAlign.center,
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: "Vat Tax",
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "(+)$_tax",
          width: 3,
          styles: PosStyles(
            align: PosAlign.center,
          )),
    ]);
    bytes += generator.row([
      // PosColumn(text: "4", width: 1),
      PosColumn(
          text: "Delivery Fee",
          width: 9,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "(+)$_deliveryCharge",
          width: 3,
          styles: PosStyles(
            align: PosAlign.center,
          )),
    ]);
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size3,
            width: PosTextSize.size3,
          )),
      PosColumn(
          text: "${PriceConverter.convertPrice(total)}",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1);

    // ticket.feed(2);
    bytes += generator.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));



    bytes += generator.text(
        'Note: Goods once sold will not be taken back or exchanged.',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }
  RxBool isNewSearch = false.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Thermal Printer'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Search Paired Bluetooth"),
              TextButton(
                onPressed: () {
                  setState(() {
                    isNewSearch.value = !isNewSearch.value;
                  });
                  this.getBluetooth();
                },
                child: Text("Search"),
              ),
              (isNewSearch.value)
                  ? Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: availableBluetoothDevices.length > 0
                            ? availableBluetoothDevices.length
                            : 0,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              // isNewSearch=!isNewSearch;
                              String select = availableBluetoothDevices[index];
                              List list = select.split("#");
                              // String name = list[0];
                              String mac = list[1];
                              this.setConnect(mac);
                            },
                            title: Text('${availableBluetoothDevices[index]}'),
                            subtitle: Text("Click to connect"),
                          );
                        },
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 30,
              ),
              TextButton(
                // onPressed:(){
                //   printwifiTicket();
                // },
                onPressed: connected.value ? this.printGraphics : null,
                child: Text("Print"),
              ),
              Center(
                child: TextButton(
                  onPressed: connected.value? this.printTicket : null,
                  child: connected.value
                      ? Text("Print Ticket")
                      : Text("Printer is not connected"),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
