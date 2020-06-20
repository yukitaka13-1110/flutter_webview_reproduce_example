import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<int> _users = [];
  final screenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    AgoraRtcEngine.stopPreview();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
  }

  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create('ae768a3aeac44800aa8a982bd52bdeb5');

    AgoraRtcEngine.enableVideo();
    AgoraRtcEngine.enableAudio();
    AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);

    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    AgoraRtcEngine.setVideoEncoderConfiguration(config);
    _addAgoraEventHandlers();
    await AgoraRtcEngine.startPreview();
    await AgoraRtcEngine.joinChannel(null, 'flutter', null, 0);
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      setState(() {
        _users.add(0);
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        setState(() {
          _users.add(uid);
        });
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame =
        (int uid, int width, int height, int elapsed) {};
  }

  @override
  Widget build(BuildContext context) {
    if (_users.isEmpty) {
      return Scaffold(
        body: Container(
          child: Center(
            child: RaisedButton(
              onPressed: () {
                _initAgoraRtcEngine();
              },
              child: Text('Enter'),
            ),
          ),
        ),
      );
    } else {
      return _usersView(context);
    }
  }

  Widget _usersView(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = _users.length == 1 ? size.height : size.height ~/ 2;
    return Scaffold(
      body: Column(
        children: [
          for (int user in _users)
            RepaintBoundary(
              key: user == 0 ? screenKey : null,
              child: Container(
                height: height,
                width: size.width,
                child: AgoraRenderWidget(
                  user,
                  local: user == 0,
                  mode: VideoRenderMode.Hidden,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          RenderRepaintBoundary boundary =
              screenKey.currentContext.findRenderObject();
          final image = await boundary.toImage();
          print(image.width);
          print(image.height);
        },
        child: Icon(Icons.photo_camera),
      ),
    );
  }
}
