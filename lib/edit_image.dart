library edit_image;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:edit_image/resources/size.resources.dart';
import 'package:edit_image/widgets/drag.widget.dart';
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
    this.floatingActionButtonColor = Colors.red,
    this.iconColor = Colors.white,
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

  Widget getPageBody(BuildContext context){
    if(widget.defaultScreen!){
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if(widget.controller!.imageEdited == false){
              setState((){
                widget.controller!.imageEdited = true;
              });
              String dir = (Platform.isIOS
                  ? await getApplicationDocumentsDirectory()
                  : await getExternalStorageDirectory())!
                  .path;
              RenderRepaintBoundary boundary = widget.controller!.globalKey!.currentContext!
                  .findRenderObject() as RenderRepaintBoundary;
              ui.Image imageCreation = await boundary.toImage(pixelRatio: 4.0);
              ByteData? byteData =
              await imageCreation.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = byteData!.buffer.asUint8List();
              final path =
              join(dir, "screenshot${DateTime.now().toIso8601String()}.png");
              File imgFile = File(path);
              imgFile.writeAsBytes(pngBytes).then((value) async {
                widget.savedImage!(value);
              });
            }
          },
          child: Icon(
            Icons.save,
            color: widget.controller!.imageEdited == true ? Colors.white : widget.iconColor,
          ),
          backgroundColor: widget.controller!.imageEdited == true ? Colors.grey : widget.floatingActionButtonColor,
        ),
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          child: SafeArea(child: getAppBar()),
          preferredSize: const Size.fromHeight(50),
        ),
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
                  child: ImageWidget(
                    controller: widget.controller!,
                    selectedFilter: widget.controller!.selectedFilter,
                    selectedColor: widget.controller!.selectedColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.grey.shade300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: height(context) * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        filterPage = 0;
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300)),
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.settings_input_composite_rounded,
                              color: filterPage == 0 ? Colors.black : Colors.grey,
                            ),
                            Text(
                              "Filtros",
                              style: TextStyle(
                                color:
                                filterPage == 0 ? Colors.black : Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        filterPage = 1;
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300)),
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.palette_rounded,
                              color: filterPage == 1 ? Colors.black : Colors.grey,
                            ),
                            Text(
                              "Cores",
                              style: TextStyle(
                                color:
                                filterPage == 1 ? Colors.black : Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
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
    }else{
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

  Widget getFilters(BuildContext context) {
    if (filterPage == 0) {
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
                      widget.controller!.selectedFilter = widget.controller!.filters![index];
                    });
                  },
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80.0),
                      child: ColorFiltered(
                          colorFilter: widget.controller!.filters![index],
                          child: widget.controller!.getImagePreview()),
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
                      widget.controller!.selectedColor = widget.controller!.filterColors[index];
                    });
                  },
                  child: Card(
                    color: widget.controller!.filterColors[index],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80.0),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              widget.controller!.filterColors[index], BlendMode.color),
                          child: widget.controller!.getImageForBackground(),
                        ),
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
        widget.controller!.imageWidth = (widget.controller!.widthPx! / pixelRatio(context));
        widget.controller!.imageHeight =
            (widget.controller!.heightPx! / pixelRatio(context));
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
