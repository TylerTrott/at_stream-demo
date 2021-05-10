import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:at_commons/at_commons.dart';
import 'package:stream_demo/screens/received_files.dart';
import 'package:at_demo_data/at_demo_data.dart' as at_demo_data;
import 'package:stream_demo/services/client_sdk_service.dart';
import 'package:stream_demo/services/server_demo_service.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Instantiate variables
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  //final String atSign;
  String activeAtSign = '';
  GlobalKey<ScaffoldState> scaffoldKey;
  List<String> atSigns;
  String shareWithAtSign;
  bool showOptions = false;
  bool isEnabled = true;

  @override
  void initState() {
    // TODO: Call function to initialize chat service.
    getAtSignAndShare();
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
  }

  // service
  ServerDemoService _serverDemoService = ServerDemoService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Welcome $activeAtSign!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text('Choose an @sign to share a file with'),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: DropdownButton<String>(
                hint: Text('\tPick an @sign'),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                ),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(fontSize: 20.0, color: Colors.black87),
                underline: Container(
                  height: 2,
                  color: Colors.deepOrange,
                ),
                onChanged: isEnabled
                    ? (String newValue) {
                        setState(() {
                          shareWithAtSign = newValue;
                          isEnabled = false;
                        });
                      }
                    : null,
                disabledHint:
                    shareWithAtSign != null ? Text(shareWithAtSign) : null,
                value: shareWithAtSign != null ? shareWithAtSign : null,
                items: atSigns == null
                    ? null
                    : atSigns.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            showOptions
                ? Column(
                    children: [
                      SizedBox(height: 20.0),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: () {
                          if (shareWithAtSign != null &&
                              shareWithAtSign.trim() != '') {
                            // TODO: Call function to set receiver's @sign
                            // setAtsignToChatWith();
                            setState(() {
                              showOptions = true;
                            });
                          } else {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(
                                      children: [Text('@sign Missing!')],
                                    ),
                                    content: Text('Please enter an @sign'),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Close'),
                                      )
                                    ],
                                  );
                                });
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(20),
                          child: FlatButton(
                            child: Text('Share'),
                            color: Colors.deepOrange,
                            textColor: Colors.white,
                            // TODO: Complete the onPressed function
                            onPressed: getAtSignAndShare,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // TODO: add the _scan, _update, and _lookup methods
  /// Create instance of an AtKey and pass that
  /// into the put() method with the corresponding
  /// _value string.
  getAtSignAndShare() async {
    //     await AtClientImpl.createClient(
    //    '@alice', '@mosphere', preference);
    // var atClient = await AtClientImpl.getClient('@alice');
    // var streamResult =
    //    await atClient.stream('@bob', 'sample_image.jpg');
    String currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      // Re-running the build method to set the active atsign as
      // the atsign currently authenticated
      activeAtSign = currentAtSign;
    });

    // Initializing a list of strings that is populated with all of the
    // testable atsigns that exist within the at_demo_data file
    List<String> allAtSigns = at_demo_data.allAtsigns;

    // This will remove the atsign that is currently authenticated
    // from the list of atsigns as choosing your own atsign to chat
    // with will result in an error
    allAtSigns.remove(activeAtSign);
    setState(() {
      // Re-running the build method to set list of atsigns as
      // the previously initialized item list
      atSigns = allAtSigns;
    });

    // Get atsign currently authenticated in and
    // atsign that user inputted
    var streamResult = await _serverDemoService.atClientInstance
        .stream(shareWithAtSign, 'wallhaven-nzjv9g.jpg');

    //     var streamResult =
    //  await atClient.stream('@bob', 'sample_image.jpg');

    print("ping!");
    // AtKey pair = AtKey();
    // pair.key = _key;
    // pair.sharedWith = widget.atSign;
    // await _serverDemoService.put(pair, _value);
  }

  /// getAtKeys() will retrieve keys shared by [atSign].
  /// Strip any meta data away from the retrieves keys. Store
  /// the keys into [_scanItems].
  // _scan() async {
  //   List<AtKey> response = await _serverDemoService.getAtKeys(
  //     sharedBy: widget.atSign,
  //   );
  //   if (response.length > 0) {
  //     List<String> scanList = response.map((atKey) => atKey.key).toList();
  //     setState(() => _scanItems = scanList);
  //   }
  // }

  // /// Create instance of an AtKey and call get() on it.
  // _lookup() async {
  //   if (_lookupKey != null) {
  //     // Initialize an AtKey object titled lookup
  //     AtKey lookup = AtKey();
  //     // Declare the attribute values such as its title (key) and the atsign
  //     // that created it
  //     lookup.key = _lookupKey;
  //     lookup.sharedWith = widget.atSign;
  //     // Initialize a string and populate it with an AtKey object
  //     // obtained from the serverDemoService's get method
  //     String response = await _serverDemoService.get(lookup);
  //     if (response != null) {
  //       // If an AtKey object exists, re-run the build method with the AtKey
  //       // object that was retrieved utilizing the get method
  //       setState(() => _lookupValue = response);
  //     }
  //   }
  // }
}
