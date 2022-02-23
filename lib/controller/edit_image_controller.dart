import 'package:flutter/material.dart';

enum ImageType { asset, file, network }

class EditImageController extends ChangeNotifier {
  EditImageController({
    @required this.src,
    @required this.imageType,
    @required this.context,
  });
  final String? src;
  final ImageType? imageType;
  final BuildContext? context;
  double imageWidth = 0.0;
  double imageHeight = 0.0;

  @override
  notifyListeners() {
    return ChangeNotifier().notifyListeners();
  }
}
