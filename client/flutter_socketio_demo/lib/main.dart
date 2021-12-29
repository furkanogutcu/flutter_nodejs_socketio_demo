import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MaterialApp(
    home: SocketIOApp(),
  ));
}

class SocketIOApp extends StatefulWidget {
  const SocketIOApp({Key? key}) : super(key: key);

  @override
  State<SocketIOApp> createState() => _SocketIOAppState();
}

class _SocketIOAppState extends State<SocketIOApp> {
  late IO.Socket socket;

  var txtMessage = TextEditingController();
  var txtResponse = TextEditingController();

  @override
  void initState() {
    socket = createSocket();
    connectServer(socket);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket-IO Demo'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
          child: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).size.height * 0.118,
        child: buildBody(),
      )),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            buildResponseField(),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
        const Spacer(),
        Padding(
            padding: const EdgeInsets.all(10.0), child: buildRequestField()),
        socketConnectionStatus(),
      ],
    );
  }

  IO.Socket createSocket() {
    return IO.io('http://10.0.2.2:3000', {
      'transports': ['websocket'],
      'autoConnect': false
    });
  }

  void connectServer(IO.Socket socket) {
    setState(() {
      socket.connect();
    });
  }

  void disconnectServer(IO.Socket socket) {
    setState(() {
      socket.disconnect();
    });
  }

  void sendMessage(IO.Socket socket, String message) {
    txtResponse.clear();
    txtMessage.clear();
    if (message == "") {
      return;
    }
    socket.emit('message', message);
    socket.on('response', (data) {
      setState(() {
        txtResponse.text = data;
        Timer(const Duration(seconds: 4), () {
          setState(() {
            txtResponse.clear();
          });
        });
      });
    });
  }

  Widget socketConnectionStatus() {
    return socket.connected
        ? Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(
                  Icons.done,
                  size: 30,
                  color: Colors.green,
                ),
                const Text(
                  "Bağlantı kuruldu",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () {
                    disconnectServer(socket);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text(
                    "Bağlantıyı kes",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          )
        : Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.red,
                ),
                const Text(
                  "Bağlantı başarısız",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    connectServer(socket);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.amber),
                  child: const Text(
                    "Bağlanmayı dene",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildInputField(TextEditingController controller, String labelText,
      TextAlign align, bool enabled) {
    return TextField(
      decoration: InputDecoration(labelText: labelText),
      textAlign: align,
      controller: controller,
      enabled: enabled,
    );
  }

  Widget buildResponseField() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
      color: socket.connected ? Colors.green : Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              socket.connected ? "SUNUCU YANITI:" : "BAĞLANTI YOK..",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
            ),
            buildInputField(txtResponse, "", TextAlign.center, false),
          ],
        ),
      ),
    );
  }

  Widget buildRequestField() {
    return socket.connected
        ? Row(
            children: [
              Expanded(
                child: buildInputField(txtMessage, "Mesajınızı girin",
                    TextAlign.start, socket.connected),
              ),
              const SizedBox(
                width: 10.0,
              ),
              ElevatedButton(
                onPressed: !socket.connected
                    ? null
                    : txtMessage.text.isNotEmpty
                        ? () {
                            sendMessage(socket, txtMessage.text);
                          }
                        : null,
                child: const Text("Mesajı yolla"),
              ),
            ],
          )
        : Container();
  }
}
