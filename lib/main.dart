import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          title: 'LED Control',
          channel: IOWebSocketChannel.connect('ws://172.22.1.42:81/')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, @required this.channel}) : super(key: key);

  final String title;
  final WebSocketChannel channel;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color _currentColor = Colors.blue;
  final _controller = CircleColorPickerController(initialColor: Colors.blue);
  int _brightness = 0;

  _MyHomePageState() {
    print("Init Main Page");
  }

  void sendColor() {
    String hex = (_currentColor.value - 4278190080).toRadixString(16);
    print(hex);
    send("#" + hex);
  }

  void sendBrightness() {
    String msg = "B_" + _brightness.toString();
    print(msg);
    send(msg);
    sendColor();
  }

  void send(String text) {
    widget.channel.sink.add(text);
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: _currentColor,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleColorPicker(
                controller: _controller,
                onChanged: (color) {
                  setState(() {
                    _currentColor = color;
                    sendColor();
                  });
                },
                size: const Size(350, 350),
                strokeWidth: 4,
                thumbSize: 36,
              ),
              Slider(
                value: _brightness.toDouble(),
                min: 0,
                max: 255,
                divisions: 255,
                onChanged: (double brightness) {
                  setState(() {
                    _brightness = brightness.toInt();
                    sendBrightness();
                  });
                },
              )
            ],
          ),
        ));
  }
}
