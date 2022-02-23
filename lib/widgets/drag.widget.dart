import 'dart:io';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:edit_image/controller/edit_image_controller.dart';
import 'package:edit_image/resources/size.resources.dart';
import 'package:flutter/material.dart';

class DragWidget extends StatefulWidget {
  final EditImageController? controller;
  final Color selectedColor;

  const DragWidget({
    Key? key,
    @required this.controller,
    this.selectedColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<DragWidget> createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  double scale = 1.0;
  double oldScale = 1.0;
  bool? draggingEnded = true;
  Offset? imagePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: imagePosition!.dy,
      left: imagePosition!.dx,
      child: GestureDetector(
        onScaleStart: (details) {
          setState(() {
              oldScale = scale;
          });
        },
        onScaleUpdate: (details) {
          setState(() {
              scale = oldScale * details.scale;
              draggingEnded = true;
              imagePosition = Offset(imagePosition!.dx+details.focalPointDelta.dx, imagePosition!.dy+details.focalPointDelta.dy);
          });
        },
        onScaleEnd: (details){
          setState(() {
              oldScale = 1.0;
          });
        },
        child: Visibility(
          visible: draggingEnded!,
          child: getEditingImage(),
        ),
      ),
    );
  }

  Widget getEditingImage(){
    return Transform(
      transform: Matrix4.diagonal3(Vector3(scale, scale, scale)),
      alignment: FractionalOffset.center,
      child: SizedBox(
          width: widget.controller!.imageWidth,
          height: widget.controller!.imageHeight,
          child: ColorFiltered(
            colorFilter:
            ColorFilter.mode(widget.selectedColor == Colors.transparent || widget.selectedColor == Color(0xff708090)? widget.selectedColor : widget.selectedColor.withOpacity(0.5), BlendMode.color),
            child: getImagePreview(),
          )),
    );
  }

  double getDyPosition() {
    if (height(context) > 785) {
      return -47;
    } else {
      return -23;
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
}
