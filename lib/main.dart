import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:movieapp/utilities/size_config.dart';

import 'dart:convert';
// ! REELDEAL - app name


// TODO: check code and clean up
// TODO: see where we are and work on improvements
// TODO: can we maximise performance on loading data? Can we load pages at a time rather than everything at once?
// TODO: work on UI

class Movie {
  Movie(this.title, this.review);

  final String title;
  final String review;

  /// Convert JSON to Movie object
  Movie.fromJson(Map<String, dynamic> json) : title = json['title'], review = json['review'];
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        canvasColor: Colors.black,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

class _MyHomePageState extends State<MyHomePage> {

  Future _future;

  Future getMovies() async {
    var url = Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=4418a4dd7da6409b55bd0876c7540a10&language=en-US&page=1');
    var response = await http.get(url);
    // print(response.body);
    final body = json.decode(response.body);
    print(body['results']);
    return body['results'];
  }

  @override
  void initState() {
    super.initState();
    _future = getMovies();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            return GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1/1.7,
                // TODO: can change the amount of grids per row based on device. On tablet we can fit many more tiles in
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 18,
              ),
              itemBuilder: (context, index) {
                return Container(
                  // color: Colors.redAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: SizeConfig.blockSizeVertical * 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage('https://image.tmdb.org/t/p/w500/${snapshot.data[index]['poster_path']}'),
                          ),
                        ),
                      ),
                      // Image.network('https://image.tmdb.org/t/p/w500/${snapshot.data[index]['poster_path']}'),

                      Expanded(
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 1, vertical: SizeConfig.blockSizeVertical * 0.4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${snapshot.data[index]['title']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${snapshot.data[index]['vote_average']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(Icons.star_rounded, color: Colors.yellow, size: 16,),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            );
          }
          return CircularProgressIndicator(); 
        },
      ),



      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       Text('You have pushed the button this many times:'),
      //       Text('$_counter', style: Theme.of(context).textTheme.headline4),
      //     ],
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
