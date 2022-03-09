library edit_image;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
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
  final int widthPx;
  final int heightPx;
  final Function(File)? savedImage;

  const EditImage({
    Key? key,
    @required this.controller,
    this.floatingActionButtonColor = Colors.red,
    this.iconColor = Colors.white,
    this.widthPx = 1060,
    this.heightPx = 1920,
    this.savedImage,
  }) : super(key: key);

  @override
  _EditImageState createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  double sliderValue = 10.0;
  Color colorFilter = Colors.transparent;
  int filterPage = 0;
  List<Color> filterColors = [
    Colors.transparent,
    const Color(0xff708090),
    ...List.generate(
      Colors.primaries.length,
      (index) => Colors.primaries[(index * 10) % Colors.primaries.length],
    )
  ];
  List<List<double>> filters = [
    ColorFilterGenerator(
        name: "No Filter",
        filters: [
          ColorFilterAddons.brightness(0),
          ColorFilterAddons.contrast(0),
          ColorFilterAddons.saturation(0),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 1",
        filters: [
          ColorFilterAddons.brightness(0),
          ColorFilterAddons.contrast(0.25),
          ColorFilterAddons.saturation(0),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 2",
        filters: [
          ColorFilterAddons.brightness(0.25),
          ColorFilterAddons.contrast(0),
          ColorFilterAddons.saturation(0),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 3",
        filters: [
          ColorFilterAddons.brightness(0.25),
          ColorFilterAddons.contrast(0.25),
          ColorFilterAddons.saturation(0),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 4",
        filters: [
          ColorFilterAddons.brightness(-0.25),
          ColorFilterAddons.contrast(0.25),
          ColorFilterAddons.saturation(0),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 5",
        filters: [
          ColorFilterAddons.brightness(-0.075),
          ColorFilterAddons.contrast(-0.25),
          ColorFilterAddons.saturation(0),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 6",
        filters: [
          ColorFilterAddons.brightness(0),
          ColorFilterAddons.contrast(0),
          ColorFilterAddons.saturation(0.25),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 7",
        filters: [
          ColorFilterAddons.brightness(0),
          ColorFilterAddons.contrast(0.25),
          ColorFilterAddons.saturation(-0.175),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 8",
        filters: [
          ColorFilterAddons.brightness(0.25),
          ColorFilterAddons.contrast(0),
          ColorFilterAddons.saturation(-1),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 9",
        filters: [
          ColorFilterAddons.brightness(0.25),
          ColorFilterAddons.contrast(0.25),
          ColorFilterAddons.saturation(-0.325),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 10",
        filters: [
          ColorFilterAddons.brightness(0),
          ColorFilterAddons.contrast(0.5),
          ColorFilterAddons.saturation(-0.20),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 11",
        filters: [
          ColorFilterAddons.brightness(-0.25),
          ColorFilterAddons.contrast(0.25),
          ColorFilterAddons.saturation(0.25),
        ]
    ).matrix,
    ColorFilterGenerator(
        name: "filter 12",
        filters: [
          ColorFilterAddons.brightness(-0.075),
          ColorFilterAddons.contrast(-0.25),
          ColorFilterAddons.saturation(0),
        ]
    ).matrix,
  ];
  List<double> selectedFilter = ColorFilterGenerator(
      name: "No Filter",
      filters: [
        ColorFilterAddons.brightness(0),
        ColorFilterAddons.contrast(0),
        ColorFilterAddons.saturation(0),
      ]
  ).matrix;
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
          ui.Image imageCreation = await boundary.toImage();
          ByteData? byteData =
              await imageCreation.toByteData(format: ui.ImageByteFormat.png);
          Uint8List pngBytes = byteData!.buffer.asUint8List();
          final path =
              join(dir, "screenshot${DateTime.now().toIso8601String()}.png");
          File imgFile = File(path);
          imgFile.writeAsBytes(pngBytes).then((value) async{
            widget.savedImage!(value);
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
                    width: (widget.widthPx / pixelRatio(context)),
                    height: (widget.heightPx / pixelRatio(context)) - 80,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: width(context),
                          height: (widget.heightPx / pixelRatio(context)) - 80,
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(
                              sigmaX: 50.0,
                              sigmaY: 50.0,
                            ),
                            child: SizedBox(
                              width: width(context),
                              height: height(context),
                              child: ColorFiltered
                                (
                                colorFilter: ColorFilter.matrix(selectedFilter),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      selectedColor == Colors.transparent ||
                                              selectedColor ==
                                                  const Color(0xff708090)
                                          ? selectedColor
                                          : selectedColor.withOpacity(0.5),
                                      BlendMode.color),
                                  child: getImageForBackground(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DragWidget(
                          controller: widget.controller,
                          selectedColor: selectedColor,
                          selectedFilter: selectedFilter,
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
              child: getFilters(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget getImagePreview() {
    switch (widget.controller!.imageType) {
      case ImageType.asset:
        return Image.asset(
          widget.controller!.src!,
          fit: BoxFit.cover,
        );
      case ImageType.file:
        return Image.file(
          File(widget.controller!.src!),
          fit: BoxFit.cover,
        );
      case ImageType.network:
        return Image.network(
          widget.controller!.src!,
          fit: BoxFit.cover,
        );
      default:
        return Container();
    }
  }

  Widget getFilters(BuildContext context){
    if(filterPage == 0){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width(context) / 1.15,
            height: 100,
            child: ListView.builder(
              itemCount: filters.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilter = filters[index];
                          });
                        },
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(80.0),
                            child: ColorFiltered
                              (
                                colorFilter: ColorFilter.matrix(filters[index]),
                                child: getImagePreview()),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          IconButton(onPressed: (){
            setState(() {
              filterPage = 1;
            });
          }, icon: Icon(Icons.keyboard_arrow_right_rounded))
        ],
      );
    }else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(onPressed: (){
            setState(() {
              filterPage = 0;
            });
          }, icon: Icon(Icons.keyboard_arrow_left_rounded),),
          SizedBox(
            width: width(context) / 1.15,
            height: 100,
            child: ListView.builder(
              itemCount: filterColors.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = filterColors[index];
                          });
                        },
                        child: Card(
                          color: filterColors[index],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)
                          ),
                          child: SizedBox(
                            width: 75,
                            height: 75,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    }
  }

  void getScreenDimensions(BuildContext context) {
    if (widget.controller!.imageWidth == 0.0 &&
        widget.controller!.imageHeight == 0.0) {
      setState(() {
        widget.controller!.imageWidth = (widget.widthPx / pixelRatio(context));
        widget.controller!.imageHeight = (widget.heightPx / pixelRatio(context));
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
      case ImageType.file:
        return Image.file(
          File(widget.controller!.src!),
          fit: BoxFit.cover,
        );
      case ImageType.network:
        return Image.network(
          widget.controller!.src!,
          fit: BoxFit.cover,
        );
      default:
        return Image.network(
          widget.controller!.src!,
          fit: BoxFit.cover,
        );
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
