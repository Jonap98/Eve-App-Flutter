import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mm_app/services/connection.dart';
import 'package:mm_app/services/led.dart';

class InitialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FlutterBluetoothSerial.instance.requestEnable(),
      builder: (context, future) {
        if (future.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              margin: EdgeInsets.only(top: 50.0),
              height: 300.0,
              child: Center(
                child: Icon(
                  FontAwesomeIcons.buyNLarge,
                  size: 200.0,
                  color: Color(0xffDC136C),
                ),
              ),
            ),
          );
        } else if (future.connectionState == ConnectionState.done) {
          return Home();
        } else {
          return Home();
        }
      },
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffDC136C),
        title: Text('Extraterrestrial Vegetation Evauator'),
      ),
      body: SelectBondedDevicePage(
        onCahtPage: (device1) {
          BluetoothDevice device = device1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ChatPage(server: device);
              },
            ),
          );
        },
      ),
    ));
  }
}
