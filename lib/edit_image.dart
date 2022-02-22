library edit_image;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:edit_image/resources/size.resources.dart';
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
  Offset? imagePosition = Offset.zero;
  double imageWidth = 0.0;
  double imageHeight = 0.0;
  double sliderValue = 10.0;
  Color colorFilter = Colors.transparent;
  List<Color> filterColors = [Colors.transparent, Color(0xffFFE1FF), Color(0xff63B8FF ), Color(0xffE3E3E3 ), ];
  List<String> filterTitle = ["Sem Filtro", "Ameixa", "Azul Claro", "Preto e Branco"];
  Color selectedColor = Colors.transparent;
  GlobalKey? globalKey = GlobalKey();
  bool? draggingEnded = true;

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
                              child: ColorFiltered(colorFilter: ColorFilter.mode(selectedColor, BlendMode.color), child: getImageForBackground(),),
                            ),
                          ),
                        ),
                        Positioned(
                          top: imagePosition!.dy - 100 + 20,
                          left: imagePosition!.dx,
                          child: Draggable(
                            feedback: SizedBox(
                                width: imageWidth,
                                height: imageHeight,
                                child: ColorFiltered(colorFilter: ColorFilter.mode(selectedColor, BlendMode.color), child: getImagePreview(),)),
                            child: Visibility(
                              visible: draggingEnded!,
                              child: SizedBox(
                                  width: imageWidth,
                                  height: imageHeight,
                                  child: ColorFiltered(colorFilter: ColorFilter.mode(selectedColor, BlendMode.color), child: getImagePreview(),)),
                            ),
                            onDragStarted: () {
                              setState(() {
                                draggingEnded = false;
                              });
                            },
                            onDraggableCanceled: (vertical, offset) {
                              setState(() {
                                print(imageWidth);
                                draggingEnded = true;
                                imagePosition = offset;
                              });
                            },
                          ),
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
              "Opções",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: height(context) * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                cardButton(
                  label: "Zoom",
                  icon: Icons.zoom_out_map,
                  clickAction: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          width: width(context),
                          height: 50,
                          child: StatefulBuilder(
                            builder: (context, state) => Slider(
                              value: sliderValue,
                              min: 10,
                              max: 1000,
                              divisions: 100,
                              activeColor: Colors.red,
                              label: sliderValue.toInt().toString(),
                              onChanged: (double value) {
                                if (value > sliderValue) {
                                  setState(() {
                                    imageWidth = imageWidth + 10;
                                    imageHeight = imageHeight + 10;
                                  });
                                } else {
                                  if(imageWidth >= (1060 / pixelRatio(context))){
                                    setState(() {
                                      imageWidth = imageWidth - 12;
                                      imageHeight = imageHeight - 12;
                                    });
                                  }
                                }
                                state(() {
                                  sliderValue = value;
                                });
                              },
                            )),
                        );
                      },
                    );
                  },
                ),
                cardButton(
                  label: "Filtro",
                  icon: Icons.filter_hdr_outlined,
                  clickAction: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          width: width(context),
                          height: 100,
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                            itemCount: filterColors.length,
                            itemBuilder: (context, index){
                              return ListTile(
                                onTap: (){
                                  setState(() {
                                    selectedColor = filterColors[index];
                                  });
                                },
                                title: Card(
                                  color: filterColors[index],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)
                                  ),
                                  child: SizedBox(width: 60, height: 60,),
                                ),
                                subtitle: Text(filterTitle[index], textAlign: TextAlign.center,),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
            SizedBox(height: height(context) * .02),
          ],
        ),
      ),
    );
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

  void getScreenDimensions(BuildContext context) {
    if (imageWidth == 0.0 && imageHeight == 0.0) {
      imageWidth = (1060 / pixelRatio(context));
      imageHeight = (1920 / pixelRatio(context));
    }
  }

  Widget getImagePreview() {
    switch (widget.controller!.imageType) {
      case ImageType.asset:
        return Image.asset(
          widget.controller!.src!,
          fit: BoxFit.contain,
        );
        break;
      case ImageType.file:
        return Image.file(
          File(widget.controller!.src!),
          fit: BoxFit.contain,
        );
        break;
      case ImageType.network:
        return Image.network(
          widget.controller!.src!,
          fit: BoxFit.contain,
        );
        break;
      default:
        return Container();
        break;
    }
  }

  Widget cardButton(
      {@required String? label,
      @required IconData? icon,
      @required Function()? clickAction}) {
    return GestureDetector(
      onTap: clickAction!,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Card(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80.0),
            ),
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
