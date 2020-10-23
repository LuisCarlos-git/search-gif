import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:search_gif/Widgets/gif_page/index.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null)
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=vnphbANt6uqh1a9ZWogXVvNVTK54yZzD&limit=25&rating=g');
    else
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=vnphbANt6uqh1a9ZWogXVvNVTK54yZzD&q=$_search&limit=25&offset=$_offset&rating=g&lang=en');

    return json.decode(response.body);
  }

  int _getConut(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGiftTable(BuildContext context, AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 10.0,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
        ),
        itemCount: _getConut(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['data'][index]['images']['fixed_height']
                    ['url'],
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (contex) => GifPages(snapshot.data['data'][index]),
                  ),
                );
              },
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']
                    ['fixed_height']['url']);
              },
            );
          } else {
            return Container(
                child: GestureDetector(
              onTap: () {
                setState(() {
                  _offset += 25;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.arrow_right,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    'Load more gifs',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )
                ],
              ),
            ));
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _getGifs().then((map) => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: TextField(
                onSubmitted: (text) {
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search gif',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGiftTable(context, snapshot);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
