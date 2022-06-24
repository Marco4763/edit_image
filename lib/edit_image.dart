library edit_image;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:edit_image/resources/size.resources.dart';
import 'package:edit_image/widgets/image.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class EditImage extends StatefulWidget {
  final EditImageController? controller;
  final bool? defaultScreen;
  final Color? floatingActionButtonColor;
  final Color? iconColor;
  final Function(File)? savedImage;
  final Widget? custom;
  final Widget? appBar;

  const EditImage({
    Key? key,
    @required this.controller,
    this.defaultScreen,
    this.floatingActionButtonColor = Colors.white,
    this.iconColor = Colors.black,
    this.savedImage,
    this.custom,
    this.appBar,
  }) : super(key: key);

  @override
  _EditImageState createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  double sliderValue = 10.0;
  Color colorFilter = Colors.transparent;
  int filterPage = 0;

  @override
  Widget build(BuildContext context) {
    getScreenDimensions(context);
    return getPageBody(context);
  }

  Widget getPageBody(BuildContext context) {
    if (widget.defaultScreen!) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          child: SafeArea(child: getAppBar()),
          preferredSize: const Size.fromHeight(50),
        ),
        body: SizedBox(
          width: width(context),
          height: height(context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ImageWidget(
                  controller: widget.controller!,
                  selectedFilter: widget.controller!.selectedFilter,
                  selectedColor: widget.controller!.selectedColor,
                ),
                SizedBox(height: height(context) * .02),
                Container(
                  color: Colors.grey.shade200,
                  child: DefaultTabController(
                    initialIndex: 0,
                    length: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: height(context) * .02),
                        const TabBar(
                            indicatorColor: Colors.black,
                            labelColor: Colors.black,
                            tabs: [
                              Tab(
                                text: "FILTROS",
                              ),
                              Tab(
                                text: "CORES",
                              ),
                            ]),
                        SizedBox(
                          width: width(context),
                          height: height(context) / 7,
                          child: TabBarView(children: [
                            SizedBox(
                              width: width(context),
                              height: 130,
                              child: getFilters(context, 0),
                            ),
                            SizedBox(
                              width: width(context),
                              height: 130,
                              child: getFilters(context, 1),
                            ),
                          ]),
                        ),
                        SizedBox(height: height(context) * .02),
                        SizedBox(
                          width: width(context),
                          height: height(context)*.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (widget.controller!.imageEdited == false) {
                                    setState(() {
                                      widget.controller!.imageEdited = true;
                                    });
                                    String dir = (Platform.isIOS
                                        ? await getApplicationDocumentsDirectory()
                                        : await getExternalStorageDirectory())!
                                        .path;
                                    RenderRepaintBoundary boundary = widget
                                        .controller!.globalKey!.currentContext!
                                        .findRenderObject() as RenderRepaintBoundary;
                                    ui.Image imageCreation = await boundary.toImage(pixelRatio: 4.0);
                                    ByteData? byteData = await imageCreation.toByteData(
                                        format: ui.ImageByteFormat.png);
                                    Uint8List pngBytes = byteData!.buffer.asUint8List();
                                    final path = join(
                                        dir, "screenshot${DateTime.now().toIso8601String()}.png");
                                    File imgFile = File(path);
                                    imgFile.writeAsBytes(pngBytes).then((value) async {
                                      widget.savedImage!(value);
                                    });
                                  }
                                },
                                child: Card(
                                  color: widget.controller!.imageEdited == true
                                      ? Colors.grey
                                      : Colors.white70,
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 7.0,
                                      top: 4.0,
                                      bottom: 4.0,
                                    ),
                                    child: Text(
                                      "Continuar",
                                      style: TextStyle(
                                          color: widget.controller!.imageEdited == true
                                              ? Colors.white
                                              : widget.iconColor),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: width(context)*.02)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return widget.custom!;
    }
  }

  Widget getAppBar() {
    if (widget.appBar == null) {
      return Container();
    } else {
      return widget.appBar!;
    }
  }

  Widget getFilters(BuildContext context, int page) {
    if (page == 0) {
      return ListView.builder(
        itemCount: widget.controller!.filters!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.controller!.selectedFilter =
                          widget.controller!.filters![index];
                    });
                  },
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ColorFiltered(
                        colorFilter: widget.controller!.filters![index],
                        child: widget.controller!.getImagePreview()),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: widget.controller!.filterColors.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.controller!.selectedColor =
                          widget.controller!.filterColors[index];
                    });
                  },
                  child: Card(
                    color: widget.controller!.filterColors[index],
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            widget.controller!.filterColors[index],
                            BlendMode.color),
                        child: widget.controller!.getImageForBackground(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void getScreenDimensions(BuildContext context) {
    if (widget.controller!.imageWidth == 0.0 &&
        widget.controller!.imageHeight == 0.0) {
      setState(() {
        widget.controller!.imageWidth =
            (widget.controller!.widthPx(context) / pixelRatio(context));
        widget.controller!.imageHeight =
            (widget.controller!.heightPx(context) / pixelRatio(context));
      });
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
