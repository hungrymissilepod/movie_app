import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:movieapp/utilities/size_config.dart';
import 'package:movieapp/utilities/ui_constants.dart';

import 'dart:convert';
// ! REELDEAL - app name


// TODO: set grid spacing
// TODO: use sliver app bar. App bar should show app name and tag line
// TODO: show bottom nav bar with two buttons. Movies with film icon, Tickets with ticket icon. Maybe also Profile with profile icon
// TODO: create splash screen. Show splash screen on app launch
// TODO: set app theme colors in ThemeData
// TODO: use correct fonts

class Movie {
  Movie({ this.title, this.voteAverage, this.imageUrl });

  final String title;
  final double voteAverage;
  final String imageUrl;

  /// Convert JSON to Movie object
  factory Movie.fromJson(Map data) {
    return Movie(
      title: data['title'] as String ?? '',
      voteAverage: data["vote_average"] is int ? (data['vote_average'] as int).toDouble() : data['vote_average'],
      imageUrl: data['poster_path'] as String ?? '',
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reel Deal',
      theme: ThemeData(
        canvasColor: Color(kBackgroundColour),
        iconTheme: IconThemeData(
          color: Color(kAccentColour), /// accent
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(kNavigationBarColour),
          selectedIconTheme: IconThemeData(color: Color(kAccentColour)),
          selectedItemColor: Color(kAccentColour),
          unselectedIconTheme: IconThemeData(color: Colors.grey),
          unselectedItemColor: Colors.grey,
        ),
        appBarTheme: AppBarTheme(
          color: Color(kAccentColour),
        ),
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _controller = ScrollController();
  int _page = 0;

  Future _future;
  List<Movie> _movies = [];
  bool _isLoading = false;

  Future getMovies() async {
    setState(() { _isLoading = true; });
    _page++;
    print('getMovies - page: $_page');
    var url = Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=4418a4dd7da6409b55bd0876c7540a10&language=en-US&page=$_page');
    var response = await http.get(url);
    // print(response.body);

    final body = json.decode(response.body);
    _movies.addAll((body['results'] as List).map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList());
    setState(() { _isLoading = false; });
    return _movies;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _future = getMovies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _onScroll() {
    /// When user gets near the bottom of the list, load more movies
    if(_controller.position.extentAfter < 500) {
      if (!_isLoading) { getMovies(); }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Movies'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _movies.length,
              controller: _controller,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1/1.5,
                // TODO: can change the amount of grids per row based on device. On tablet we can fit many more tiles in
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 18,
              ),
              itemBuilder: (context, index) {
                return MoviePoster(
                  _movies[index].title,
                  _movies[index].voteAverage,
                  _movies[index].imageUrl,
                );
              }
            );
          }
          return Center(child: CircularProgressIndicator()); 
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            label: 'Movies',
            icon: Icon(Icons.theaters),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_rounded),
          ),
        ],
      ),
    );
  }
}


class MoviePoster extends StatelessWidget {
  MoviePoster(this.title, this.vote, this.imageUrl);
  final String title;
  final double vote;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    double stars = vote / 2; /// convert vote score to number of stars
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Container(
          child: FittedBox(
            fit: BoxFit.fill,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              child: Image.network('https://image.tmdb.org/t/p/w500/$imageUrl')),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ Colors.transparent, Colors.black87.withOpacity(0.35), Colors.black87 ],
              )
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 3, horizontal: SizeConfig.blockSizeHorizontal * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 1),
                  Row(
                    children: List.generate(5, (index) {
                      IconData icon = Icons.star_outline_rounded; /// default to empty star
                      /// If this movie has more stars than [index+1], show a full star
                      if (stars > index+1) {
                        icon = Icons.star_rounded;
                        /// check if this movie can get half a star. Check if stars are more than [index] and that stars is greater by 0.5, show a half star
                      } else if (stars > index && (stars - index) >= 0.5) {
                        icon = Icons.star_half_rounded;
                      }
                      return Icon(icon,  size: SizeConfig.blockSizeVertical * 3);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}