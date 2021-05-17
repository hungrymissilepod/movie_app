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