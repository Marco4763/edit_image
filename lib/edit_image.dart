library edit_image;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:edit_image/resources/size.resources.dart';
import 'package:edit_image/widgets/drag.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class EditImage extends StatefulWidget {
  final EditImageController? controller;
  final Color? floatingActionButtonColor;
  final Color? iconColor;
  final Function(File)? savedImage;

  const EditImage({
    Key? key,
    @required this.controller,
    this.floatingActionButtonColor = Colors.red,
    this.iconColor = Colors.white,
    this.savedImage,
  }) : super(key: key);

  @override
  _EditImageState createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  double sliderValue = 10.0;
  Color colorFilter = Colors.transparent;
  List<Color> filterColors = [
    Colors.transparent,
    Color(0xff708090),
    ...List.generate(
      Colors.primaries.length,
          (index) => Colors.primaries[(index * 10) % Colors.primaries.length],
    )
  ];
  Color selectedColor = Colors.transparent;
  GlobalKey? globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    getScreenDimensions(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String dir = (Platform.isIOS
                  ? await getApplicationDocumentsDirectory()
                  : await getExternalStorageDirectory())!
              .path;
          RenderRepaintBoundary boundary = globalKey!.currentContext!
              .findRenderObject() as RenderRepaintBoundary;
          ui.Image image = await boundary.toImage();
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          Uint8List pngBytes = byteData!.buffer.asUint8List();
          final path =
              join(dir, "screenshot${DateTime.now().toIso8601String()}.png");
          File imgFile = File(path);
          imgFile.writeAsBytes(pngBytes).then((value) {
            widget.savedImage!(value);
          }).catchError((onError) {
            print(onError);
          });
        },
        child: Icon(
          Icons.save,
          color: widget.iconColor,
        ),
        backgroundColor: widget.floatingActionButtonColor,
      ),
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width(context),
            height: height(context),
            child: Center(
              child: Card(
                color: Colors.grey.shade300.withOpacity(0.5),
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    side: BorderSide(
                  color: Colors.red,
                  width: 5.0,
                )),
                child: RepaintBoundary(
                  key: globalKey,
                  child: SizedBox(
                    width: (1060 / pixelRatio(context)),
                    height: (1920 / pixelRatio(context)) - 80,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: width(context),
                          height: (1920 / pixelRatio(context)) - 80,
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(
                              sigmaX: 5.0,
                              sigmaY: 5.0,
                            ),
                            child: SizedBox(
                              width: width(context),
                              height: height(context),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(selectedColor == Colors.transparent || selectedColor == Color(0xff708090)? selectedColor : selectedColor.withOpacity(0.5), BlendMode.color),
                                child: getImageForBackground(),
                              ),
                            ),
                          ),
                        ),
                        DragWidget(
                          controller: widget.controller,
                          selectedColor: selectedColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: height(context) * .02),
            const Text(
              "Filtros",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: height(context) * .02),
            SizedBox(
              width: width(context),
              height: 130,
              child: ListView.builder(
                itemCount: filterColors.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: width(context)*.28,
                    height: 50,
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          selectedColor = filterColors[index];
                        });
                      },
                      title: Card(
                        color: filterColors[index],
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(80.0)),
                        child: Padding(padding: EdgeInsets.all(35.0)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getScreenDimensions(BuildContext context) {
    if (widget.controller!.imageWidth == 0.0 &&
        widget.controller!.imageHeight == 0.0) {
      setState(() {
        widget.controller!.imageWidth = (1060 / pixelRatio(context));
        widget.controller!.imageHeight = (1920 / pixelRatio(context));
      });
    }
  }

  Widget getImageForBackground() {
    switch (widget.controller!.imageType) {
      case ImageType.asset:
        return Image.asset(
          widget.controller!.src!,
          fit: BoxFit.cover,
        );
        break;
      case ImageType.file:
        return Image.file(
          File(widget.controller!.src!),
          fit: BoxFit.cover,
        );
        break;
      case ImageType.network:
        return Image.network(
          widget.controller!.src!,
          fit: BoxFit.cover,
        );
        break;
      default:
        return Image.network(
          widget.controller!.src!,
          fit: BoxFit.cover,
        );
        break;
    }
  }

  Widget cardButton({
    @required String? label,
    @required IconData? icon,
    Color? sideColor = Colors.black,
    @required Function()? clickAction,
  }) {
    return GestureDetector(
      onTap: clickAction!,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0),
                side: BorderSide(
                  color: sideColor!,
                  width: 1.0,
                )),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon!),
            ),
          ),
          Text(label!)
        ],
      ),
    );
  }
}
