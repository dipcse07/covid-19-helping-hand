import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:helping_hand/components/progress.dart';
import 'package:helping_hand/config/FadeAnimation.dart';
import 'package:helping_hand/config/config.dart';
import 'package:helping_hand/models/requestItemBuild.dart';
import 'package:helping_hand/screens/userProfileScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final usersRef = Firestore.instance.collection('userRequests');
final auth = FirebaseAuth.instance;

bool showSpinner = false;

class requestDisplay extends StatefulWidget {
  @override
  _requestDisplayState createState() => _requestDisplayState();
}

class _requestDisplayState extends State<requestDisplay>
    with AutomaticKeepAliveClientMixin {
  String me;
  bool get wantKeepAlive => true;

  Future<void> get_me() async {
    final auth = FirebaseAuth.instance;
    final FirebaseUser sender = await auth.currentUser();
    final senderID = sender.uid;

    setState(() {
      me = senderID;
    });
  }

  @override
  void initState() {
    get_me();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //this little code down here turns off auto rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: primaryColor,
          automaticallyImplyLeading: false,
          title: Text(
            "Help Forum",
            style: requestTitleTextStyle,
          ),
          actions: <Widget>[
            // IconButton(
            //   icon: Icon(Icons.arrow_back),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => UserProfile(),
            //       ),
            //     );
            //   },
            // )
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                underline: SizedBox(),
                icon: Icon(
                  Icons.not_listed_location,
                  color: Colors.white,
                ),
                items: [
                  'All Requests',
                  'Request Nearby',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  //Code goes here
                },
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            //on refresh action
          },
          child: Container(
            child: StreamBuilder(
                stream:
                    Firestore.instance.collection('helpRequests').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('loading...');
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot userID =
                              snapshot.data.documents[index];
                          return FutureBuilder(
                            future: Firestore.instance
                                .collection(
                                    'helpRequests/${userID['userID']}_${userID['postID']}/userPost')
                                .getDocuments(),
                            builder:
                                (BuildContext context, AsyncSnapshot snap) {
                              if (!snap.hasData) {
                                return circularProgress();
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                //setState(() {});
                                if (snap.data.documents
                                        .toList()[0]
                                        .data['ownerID'] !=
                                    me) {
                                  return FadeAnimation(
                                    1.2,
                                    buildRequestItem(
                                      title: snap.data.documents
                                          .toList()[0]
                                          .data['title']
                                          .toString(),
                                      desc: snap.data.documents
                                          .toList()[0]
                                          .data['description']
                                          .toString(),
                                      geoPoint: snap.data.documents
                                          .toList()[0]
                                          .data['location'],
                                      name: snap.data.documents
                                          .toList()[0]
                                          .data['name']
                                          .toString(),
                                      foodRelated: snap.data.documents
                                          .toList()[0]
                                          .data['foodRelated'],
                                      postID: snap.data.documents
                                          .toList()[0]
                                          .data['postID'],
                                      ownerID: snap.data.documents
                                          .toList()[0]
                                          .data['ownerID'],
                                    ),
                                  );
                                }
                              }
                              return Container(width: 0.0, height: 0.0);
                            },
                          );
                        });
                  }
                }),
          ),
        ),
      ),
    );
  }
}
