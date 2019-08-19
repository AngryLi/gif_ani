import 'package:flutter/material.dart';
import 'package:gif_ani/gif_ani.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  GifController _animationCtrl;

  @override
  void initState() {
    super.initState();
    _animationCtrl = GifController(
      vSync: this,
      duration: Duration(milliseconds: 1200),
      frameCount: 35,
    );
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton.icon(
              icon: Icon(Icons.satellite),
              label: Text("开始动画"),
              onPressed: () {
                _animationCtrl.runAni();
              },
            ),
            RaisedButton.icon(
              icon: Icon(Icons.satellite),
              label: Text("指定帧"),
              onPressed: () {
                _animationCtrl.setFrame(10);
              },
            ),
            RaisedButton.icon(
              icon: Icon(Icons.satellite),
              label: Text("循环动画"),
              onPressed: () {
                _animationCtrl.repeat();
              },
            ),
//            _buildGif(),
            Image(image: AssetImage('images/like_anim.gif')),
            _buildGif(),
          ],
        ),
      ),
    );
  }

  Widget _buildGif() {
    return Container(
      height: 40,
      width: 40,
      child: GifAnimation(
        image: AssetImage('images/like_anim.gif'),
        controller: _animationCtrl,
      ),
    );
  }
}
