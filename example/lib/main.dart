import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:edit_image/edit_image.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = EditImageController(
      src:
          "https://www.slazzer.com/static/images/home-page/banner-orignal-image.jpg",
      imageType: ImageType.network,
      context: context,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EditImage(
        controller: controller,
        savedImage: (value){
          Navigator.pop(context);
        },
        widthPx: 1080,
        heightPx: 1200,
      ),
    );
  }
}
