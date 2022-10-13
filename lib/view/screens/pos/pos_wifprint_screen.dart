import 'dart:async';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

class PosWifiPrintScreen extends StatefulWidget {
  @override
  _PosWifiPrintScreenState createState() => _PosWifiPrintScreenState();
}

class _PosWifiPrintScreenState extends State<PosWifiPrintScreen> {
  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableWifiDevices = [];

  Future<void> getBluetooth() async {
    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableWifiDevices = bluetooths;
    });
  }
  Future<void> getWifi() async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);
    final PosPrintResult res = await printer.connect('192.168.0.123', port: 9100);
    if (res == PosPrintResult.success) {
    setState(() {
      connected = true;
    });}
  }
  Future<void> setConnect(String mac) async {
    final String result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }
  Future<void> printwifiTicket() async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);
    // List<int> bytes = await getTicket();
    // print(bytes);
    print("============");
    final PosPrintResult res = await printer.connect('192.168.0.123', port: 9100);
    print("======result:${res.msg}========");
    if (res == PosPrintResult.success) {
      print("======result:${res.msg}========");
      testReceipt(printer);
      setState(() {
        connected = true;
      });
      // testReceipt(printer);
      // List<int> bytes = await getTicket();
      // final result = await BluetoothThermalPrinter.writeBytes(bytes);
      // print("Print $result");
      // printer.disconnect();
    }

    print('Print result: ${res.msg}');
  }
  Future<void> finddevice() async {
    const port = 80;
    final stream = NetworkAnalyzer.discover2(
      '192.168.0',
      port,
      timeout: Duration(milliseconds: 5000),
    );

    int found = 0;
    stream.listen((NetworkAddress addr) {
      print("start to listen");
      print('${addr.ip}:$port');
      if (addr.exists) {
        found++;
        print('Found device: ${addr.ip}:$port');
      }
    }).onDone(() => print('Finish. Found $found device(s)'));
  }
  Future<void> printTicket() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }
  Future<void> printGraphics() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
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
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }
  void testReceipt(NetworkPrinter printer) {

    printer.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: 'CP1252'));

    printer.text('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: 'CP1252'));
    printer.text('Bold text', styles: PosStyles(bold: true));
    printer.text('Reverse text', styles: PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: PosStyles(align: PosAlign.left));
    printer.text('Align center', styles: PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.feed(2);
    printer.cut();
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text("Demo Shop",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(
        "18th Main Road, 2nd Phase, J. P. Nagar, Bengaluru, Karnataka 560078",
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Tel: +919591708470',
        styles: PosStyles(align: PosAlign.center));

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

    bytes += generator.row([
      PosColumn(text: "1", width: 1),
      PosColumn(
          text: "Tea",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "10",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "10", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "2", width: 1),
      PosColumn(
          text: "Sada Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "30",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "30", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "3", width: 1),
      PosColumn(
          text: "Masala Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "50",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "50", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "4", width: 1),
      PosColumn(
          text: "Rova Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "70",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "70", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: "160",
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

    bytes += generator.text("26-11-2020 15:22:45",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text(
        'Note: Goods once sold will not be taken back or exchanged.',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }
  void initstate(){
    printwifiTicket();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wifi  Printer'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text("Search Paired Bluetooth"),
            // TextButton(
            //   onPressed: () {
            //     this.getBluetooth();
            //   },
            //   child: Text("Search"),
            // ),
            // Container(
            //   height: 200,
            //   child: ListView.builder(
            //     itemCount: availableWifiDevices.length > 0
            //         ? availableWifiDevices.length
            //         : 0,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         onTap: () {
            //           String select = availableWifiDevices[index];
            //           List list = select.split("#");
            //           // String name = list[0];
            //           String mac = list[1];
            //           this.setConnect(mac);
            //         },
            //         title: Text('${availableWifiDevices[index]}'),
            //         subtitle: Text("Click to connect"),
            //       );
            //     },
            //   ),
            // ),
            // SizedBox(
            //   height: 30,
            // ),
            // TextButton(
            //   // onPressed:(){
            //   //   printwifiTicket();
            //   // },
            //   onPressed: connected ? this.printGraphics : null,
            //   child: Text("Print"),
            // ),
            Container(
              alignment: Alignment.center,
              child: TextButton(
                // onPressed: () async {
                //   try {
                //    // var ip = await Wifi.ip;
                //    //  print('local ip:\t$ip');
                //   } catch (e) {
                //     final snackBar = SnackBar(
                //         content: Text('WiFi is not connected', textAlign: TextAlign.center));
                //     Scaffold.of(context).showSnackBar(snackBar);
                //     return;
                //   }
                // },
                onPressed: true ? this.finddevice : null,
                child: Text("Print Ticket"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}