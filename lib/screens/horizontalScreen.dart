import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cdlitablet/model/model.dart';
import 'package:cdlitablet/screens/verticalScreen.dart';
import 'package:cdlitablet/services/dataServices.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HorizontalScreen extends StatefulWidget {
  HorizontalScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HorizontalScreenState createState() => _HorizontalScreenState();
}

class _HorizontalScreenState extends State<HorizontalScreen> {
  final ApiResponse dataState = ApiResponse();
  int _current;
  String _currentUri;

  @override
  void initState() {
    dataState.getCDLI();
    _current = 0;
    _currentUri =
        'https://cdli.ucla.edu/dl/daily_tablets/RSM7-521c91d137921_thumbnail.jpg';
    super.initState();
  }

  Future<void> _shareImageFromUrl() async {
    try {
      var request = await HttpClient().getUrl(Uri.parse(_currentUri));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file('CDLI Tablet', 'cdli.jpg', bytes, 'image/jpg');
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () async => await _shareImageFromUrl(),
          ),
          IconButton(
            icon: Icon(Icons.apps, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (BuildContext context) {
                return VerticalScreen(title: 'CDLI tablet');
              }));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Cdli>>(
        future: dataState.getCDLI(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? SlidingUpPanel(
                  parallaxEnabled: true,
                  parallaxOffset: 0.4,
                  renderPanelSheet: false,
                  panelSnapping: true,
                  backdropEnabled: false,
                  slideDirection: SlideDirection.UP,
                  panel: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20.0,
                            color: Colors.black,
                          ),
                        ]),
                    margin: const EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0)),
                            ),
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(
                                    12.0, 12.0, 12.0, 14.0),
                                child: Text(
                                  snapshot.data[_current].blurbTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: Html(
                                  data: snapshot.data[_current].fullInfo,
                                  defaultTextStyle: TextStyle(fontSize: 10.0),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  collapsed: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0)),
                    ),
                    margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                    child: Center(
                      child: Text(
                        snapshot.data[_current].blurbTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ),
                  body: CarouselSlider.builder(
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    onPageChanged: (index) {
                      setState(() {
                        _current = index;
                        _currentUri = snapshot.data[index].thumbnailUrl;
                      });
                    },
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) => PhotoView(
                      imageProvider:
                          NetworkImage(snapshot.data[index].thumbnailUrl),
                      backgroundDecoration: BoxDecoration(color: Colors.black),
                    ),
                  ),
                )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
