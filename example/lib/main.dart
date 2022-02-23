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
          "https://pagesix.com/wp-content/uploads/sites/3/2014/06/168286248.jpg?quality=80&strip=all&w=900",
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
      ),
    );
  }
}
