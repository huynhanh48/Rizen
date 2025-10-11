import 'package:flutter_svg/flutter_svg.dart';

class ImageHome {
  final String path;
  final String semanticslabel;
  final String title;
  final String subtitle;
  ImageHome({
    required this.path,
    required this.semanticslabel,
    this.title = "",
    this.subtitle = "",
  });
  SvgPicture get svg => SvgPicture.asset(path, semanticsLabel: semanticslabel);
}
