import 'package:flutter/material.dart';

/// Utilities
import 'package:movieapp/utilities/size_config.dart';

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
              padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 2, horizontal: SizeConfig.blockSizeHorizontal * 2),
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
                        /// Check if this movie can get half a star. If stars are more than [index] and stars is greater by 0.5, show a half star
                      } else if (stars > index && (stars - index) >= 0.5) {
                        icon = Icons.star_half_rounded;
                      }
                      return Icon(icon, size: SizeConfig.blockSizeVertical * 3);
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