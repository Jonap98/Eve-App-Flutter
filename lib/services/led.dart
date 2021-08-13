import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class Subtitulo {
  String content;

  Subtitulo({this.content = ''});
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = [];
  String _messageBuffer = '';
  String subtitleMessage = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  bool plant1 = false;
  bool plant2 = false;
  bool plant3 = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffDC136C),
        title: (isConnecting
            ? Text('Conectando con EVE...')
            : isConnected
                ? Text('En linea con EVE')
                : Text('Desconectado de EVE')),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              width: 200,
              height: 200,
              child: Image.asset('images/Eve.png'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Modo Bluetooth',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              isConnecting
                  ? 'Conectando...'
                  : (subtitleMessage == '0')
                      ? 'Seleccione su planta'
                      : 'Regando planta $subtitleMessage',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 50.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              width: double.infinity,
              height: 120.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 70,
                        child: FittedBox(
                          child: FloatingActionButton(
                            backgroundColor: Color(0xff89c445),
                            child: FaIcon(FontAwesomeIcons.leaf),
                            onPressed:
                                isConnected ? () => _sendMessage('1') : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Planta 1',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 70,
                        child: FittedBox(
                          child: FloatingActionButton(
                            backgroundColor: Color(0xff89c445),
                            child: FaIcon(FontAwesomeIcons.leaf),
                            onPressed:
                                isConnected ? () => _sendMessage('2') : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Planta 2',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: 70,
                        child: FittedBox(
                          child: FloatingActionButton(
                            backgroundColor: Color(0xff89c445),
                            child: FaIcon(FontAwesomeIcons.leaf),
                            onPressed:
                                isConnected ? () => _sendMessage('3') : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Planta 3',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50.0),
            Container(
              height: 100.0,
              child: FittedBox(
                child: FloatingActionButton(
                  backgroundColor: Color(0xffDC136C),
                  child: FaIcon(FontAwesomeIcons.powerOff),
                  onPressed: isConnected ? () => _sendMessage('0') : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
          subtitleMessage = text.trim();
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
