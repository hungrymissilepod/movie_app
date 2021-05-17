import 'package:flutter/material.dart';
import 'dart:convert' show json;

/// Utilities
import 'package:movieapp/utilities/ui_constants.dart';
import 'package:movieapp/utilities/size_config.dart';
import 'package:http/http.dart' as http;

/// Models
import 'package:movieapp/models/movie_model.dart';

/// Widgets
import 'package:movieapp/widgets/movie_poster_widget.dart';

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
      debugShowCheckedModeBanner: false,
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

  /// ScrollController so we can detect when user is near the bottom of the screen
  ScrollController _controller = ScrollController();

  /// Future for FutureBuilder so we can wait until movies have loaded
  Future _future;

  /// List of [Movie] objects we will display in scroll view
  List<Movie> _movies = [];
  
  /// The current page of data we are loading from API
  int _page = 0;

  /// Are we currently loading data from the API? Helps reduce the amount of data loaded at once
  bool _isLoading = false;

  Future getMovies() async {
    setState(() { _isLoading = true; _page++; });
    print('getMovies - page: $_page');

    /// Get movie data for this [_page]
    var url = Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=4418a4dd7da6409b55bd0876c7540a10&language=en-US&page=$_page');
    var response = await http.get(url);
    
    /// Deserialise reponse body to json
    final body = json.decode(response.body);
    /// Convert json to list of movies and add them to [_movies] list
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
    double gridPadding = SizeConfig.blockSizeHorizontal * 3;
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: gridPadding),
              child: CustomScrollView(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                controller: _controller,
                slivers: [
                  SliverAppBar(
                    brightness: Brightness.dark,
                    backgroundColor: Color(kBackgroundColour),
                    toolbarHeight: SizeConfig.blockSizeVertical * 22,
                    title: Container(
                      child: Column(
                        children: [
                          Image(
                            image: AssetImage('assets/movie_reel.png'),
                            height: SizeConfig.blockSizeVertical * 6,
                          ),
                          Text(
                            'REEL DEALS',
                            style: TextStyle(
                              fontFamily: 'CFParis',
                              color: Color(kAccentColour),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              fontSize: 70,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Find the best movie deals for you',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1/1.5,
                      crossAxisSpacing: gridPadding,
                      mainAxisSpacing: gridPadding,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return MoviePoster(
                          _movies[index].title,
                          _movies[index].voteAverage,
                          _movies[index].imageUrl,
                        );
                      },
                      childCount: _movies.length,
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            label: 'Watchlist',
            icon: Icon(Icons.bookmark),
          ),
          BottomNavigationBarItem(
            label: 'Movies',
            icon: Icon(Icons.theaters),
          ),
          BottomNavigationBarItem(
            label: 'Search',
            icon: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}