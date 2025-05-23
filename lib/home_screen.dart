import 'package:flutter/material.dart';
import 'sendbird_channels.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _calleeController = TextEditingController();

  bool _isCalleeAvailable = false;
  bool _areCalling = false;
  bool _areConnected = false;
  bool _isCallActive = false;
  bool _areReceivingCall = false;

  String? callerId;
  String? callerNickname;
  SendbirdChannels? channels;

  final appId = "A667513B-411E-404A-B3CA-C0EBD88DD52E";
  final userId = "sample_code_flutter_ios";

  @override
  void initState() {
    channels = SendbirdChannels(directCallReceived: ((userId, nickname) {
      setState(() {
        callerId = userId;
        callerNickname = nickname;
        _areReceivingCall = true;
      });
    }), directCallConnected: () {
      setState(() {
        _areCalling = false;
        _areReceivingCall = false;
        _isCallActive = true;
      });
    }, directCallEnded: () {
      setState(() {
        _isCallActive = false;
        _areCalling = false;
        _areReceivingCall = false;
        callerId = null;
        callerNickname = null;
      });
    }, onError: ((message) {
      print(
          "home_screen.dart: initState: SendbirdChannels: onError: message: $message");
    }), onLog: ((message) {
      print(
          "home_screen.dart: initState: SendbirdChannels onLog: message: $message");
    }));
    channels
        ?.initSendbird(
          appId: appId,
          userId: userId,
        )
        .then((value) => setState(() {
              _areConnected = value;
            }));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Sendbird Calls'))),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(children: [
          Row(children: [
            SizedBox(width: 240, child: Text("Connection status for $userId:")),
            Expanded(child: statusField()),
          ]),
          Container(height: 20),
          // statusField(),
          Row(children: [
            SizedBox(width: 80, child: Text("Calling")),
            Container(width: 10),
            SizedBox(width: 150, child: calleeIdField(_calleeController)),
            Container(width: 10),
            Expanded(
                child: _isCalleeAvailable
                    ? _areConnected && !_isCallActive && !_areCalling
                        ? callButton(_calleeController)
                        : Container()
                    : Container()),
          ]),
          Container(height: 20),
          Row(children: [
            SizedBox(width: 80, child: Text('Receiving')),
            Container(width: 10),
            SizedBox(
              width: 150,
              child: callerNickname != null
                  ? Text('$callerNickname')
                  : callerId != null
                      ? Text("$callerId")
                      : Text("<No incoming calls>"),
            ),
            Expanded(
                child: _areReceivingCall ? receivingCallButton() : Container()),
            Container(height: 20),
          ]),
          Container(height: 10),
          _isCallActive || _areCalling ? hangupButton() : Container(),
        ]),
      ),
    );
  }

  Widget dialRow() {
    return Expanded(
      child: Row(children: [
        Text("Dial"),
        Container(width: 10),
        calleeIdField(_calleeController),
        Container(width: 10),
        _isCallActive ? hangupButton() : callButton(_calleeController)
      ]),
    );
  }

  Widget receiveRow() {
    return Expanded(
      child: Row(children: [
        Text('Receiving calls'),
        Container(width: 10),
        callerNickname != null
            ? Text('$callerNickname')
            : callerId != null
                ? Text("$callerId")
                : Container(),
        _areReceivingCall ? receivingCallButton() : Container(),
        callerId != null && _isCallActive ? hangupButton() : Container(),
      ]),
    );
  }

  Widget statusField() {
    return Container(
        child: _areConnected
            ? Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40.0,
              )
            : Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
                size: 40.0,
              ));
  }

  Widget calleeIdField(TextEditingController calleeController) {
    return Container(
      child: TextField(
        controller: calleeController,
        onChanged: (text) {
          setState(() {
            _isCalleeAvailable = text.isNotEmpty;
          });
        },
        decoration: InputDecoration(labelText: "Callee User Id"),
      ),
    );
  }

  Widget callButton(TextEditingController controller) {
    return Container(
      child: ElevatedButton(
        onPressed: () async {
          channels?.startCall(controller.text);
          setState(() {
            _areCalling = true;
          });
        },
        child: Icon(
          Icons.call,
          color: Colors.green,
          size: 20.0,
        ),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          // primary: Colors.green, // <-- Button color
          // onPrimary: Colors.green, // <-- Splash color
        ),
      ),
    );
  }

  Widget receivingCallButton() {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          channels?.pickupCall();
        },
        child: Icon(
          Icons.call,
          color: Colors.blue,
          size: 20.0,
        ),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          // primary: Colors.white, // <-- Button color
          // onPrimary: Colors.white, // <-- Splash color
        ),
      ),
    );
  }

  Widget hangupButton() {
    return Container(
      padding: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          channels?.endCall();
        },
        child: Icon(
          Icons.call_end,
          color: Colors.red,
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(20),
          shape: CircleBorder(),
          // primary: Colors.red, // <-- Button color
          // onPrimary: Colors.red, // <-- Splash color
        ),
      ),
    );
  }
}
