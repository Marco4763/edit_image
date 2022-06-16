import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:edit_image/resources/size.resources.dart';
import 'package:edit_image/widgets/drag.widget.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImageWidget extends StatefulWidget {
  final EditImageController? controller;
  final ColorFilter? selectedFilter;
  final Color? selectedColor;

  const ImageWidget({
    Key? key,
    @required this.controller,
    @required this.selectedFilter,
    @required this.selectedColor,
  }) : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.controller!.globalKey,
      child: SizedBox(
        width: (widget.controller!.widthPx(context) / pixelRatio(context)*1.5),
        height: (widget.controller!.heightPx(context) / pixelRatio(context)) - 80,
        child: Stack(
          children: [
            SizedBox(
              width: width(context),
              height: (widget.controller!.heightPx(context) / pixelRatio(context)) - 80,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: 50.0,
                  sigmaY: 50.0,
                ),
                child: SizedBox(
                  width: width(context),
                  height: height(context),
                  child: ColorFiltered(
                    colorFilter: widget.selectedFilter!,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          widget.selectedColor! == Colors.transparent ||
                                  widget.selectedColor! ==
                                      const Color(0xff708090)
                              ? widget.selectedColor!
                              : widget.selectedColor!.withOpacity(0.5),
                          BlendMode.color),
                      child: widget.controller!.getImageForBackground(),
                    ),
                  ),
                ),
              ),
            ),
            DragWidget(
              controller: widget.controller,
              selectedColor: widget.selectedColor!,
              selectedFilter: widget.selectedFilter!,
            ),
          ],
        ),
      ),
    );
  }
}
