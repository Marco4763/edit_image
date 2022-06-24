import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAppBody(),
    );
  }
}

class MyAppBody extends StatefulWidget {
  const MyAppBody({Key? key}) : super(key: key);

  @override
  _MyAppBodyState createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
  EditImageController? controller;
  Widget filterWidget = Container();
  var selected = ColorFilter.mode(Color(0xffff9800), BlendMode.softLight);

  @override
  Widget build(BuildContext context) {
    controller = EditImageController(
      src:"https://www.slazzer.com/static/images/home-page/banner-orignal-image.jpg",
      imageType: ImageType.network,
      context: context,
      initialWidthPx: 1440,
      initialHeightPx: 1700,
    );
    print(controller!.selectedFilter);
    return controller!.defaultScreen(
        savedImage: (value){
          Navigator.pop(context);
        },
    );
  }

  Widget buildFilter(){
    return StatefulBuilder(builder: (context, updateState){
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: ListView.builder(
          itemCount: controller!.filters!.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      updateState(() {
                        selected = controller!.filters![index];
                        print("Here");
                        print(selected);
                      });
                    },
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80.0),
                        child: ColorFiltered(
                            colorFilter: controller!.filters![index],
                            child: controller!.getImagePreview()),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text("Filtro $index"),
                )
              ],
            );
          },
        ),
      );
    });
  }
}

