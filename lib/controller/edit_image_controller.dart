import 'dart:io';

import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:edit_image/edit_image.dart';
import 'package:edit_image/widgets/image.widget.dart';
import 'package:flutter/material.dart';

enum ImageType { asset, file, network }

class EditImageController extends ChangeNotifier {
  EditImageController({
    @required this.src,
    @required this.imageType,
    @required this.context,
    this.widthPx = 1060,
    this.heightPx = 1920,
  });
  final String? src;
  final ImageType? imageType;
  final BuildContext? context;
  final int? widthPx;
  final int? heightPx;
  double imageWidth = 0.0;
  double imageHeight = 0.0;
  GlobalKey? globalKey = GlobalKey();
  List<Color> filterColors = [
    Colors.transparent,
    const Color(0xff708090),
    ...List.generate(
      Colors.primaries.length,
          (index) => Colors.primaries[(index * 10) % Colors.primaries.length],
    )
  ];
  List? filters;
  ColorFilter selectedFilter = ColorFilter.matrix(ColorFilterGenerator(name: "No Filter", filters: [
    ColorFilterAddons.brightness(0),
    ColorFilterAddons.contrast(0),
    ColorFilterAddons.saturation(0),
  ]).matrix);
  Color selectedColor = Colors.transparent;
  bool imageEdited = false;

  @override
  notifyListeners() {
    return ChangeNotifier().notifyListeners();
  }

  void setFilters(){
    filters = [
      ColorFilter.matrix(ColorFilterGenerator(name: "No Filter", filters: [
        ColorFilterAddons.brightness(0),
        ColorFilterAddons.contrast(0),
        ColorFilterAddons.saturation(0),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 1", filters: [
        ColorFilterAddons.brightness(0),
        ColorFilterAddons.contrast(0.25),
        ColorFilterAddons.saturation(0),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 2", filters: [
        ColorFilterAddons.brightness(0.25),
        ColorFilterAddons.contrast(0),
        ColorFilterAddons.saturation(0),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 3", filters: [
        ColorFilterAddons.brightness(0.25),
        ColorFilterAddons.contrast(0.25),
        ColorFilterAddons.saturation(0),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 4", filters: [
        ColorFilterAddons.brightness(-0.25),
        ColorFilterAddons.contrast(0.25),
        ColorFilterAddons.saturation(0),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 5", filters: [
        ColorFilterAddons.brightness(-0.075),
        ColorFilterAddons.contrast(-0.25),
        ColorFilterAddons.saturation(0),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 6", filters: [
        ColorFilterAddons.brightness(0),
        ColorFilterAddons.contrast(0),
        ColorFilterAddons.saturation(0.25),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 7", filters: [
        ColorFilterAddons.brightness(0),
        ColorFilterAddons.contrast(0.25),
        ColorFilterAddons.saturation(-0.175),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 8", filters: [
        ColorFilterAddons.brightness(0.25),
        ColorFilterAddons.contrast(0),
        ColorFilterAddons.saturation(-1),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 9", filters: [
        ColorFilterAddons.brightness(0.25),
        ColorFilterAddons.contrast(0.25),
        ColorFilterAddons.saturation(-0.325),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 10", filters: [
        ColorFilterAddons.brightness(0),
        ColorFilterAddons.contrast(0.5),
        ColorFilterAddons.saturation(-0.20),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 11", filters: [
        ColorFilterAddons.brightness(-0.25),
        ColorFilterAddons.contrast(0.25),
        ColorFilterAddons.saturation(0.25),
      ]).matrix),
      ColorFilter.matrix(ColorFilterGenerator(name: "filter 12", filters: [
        ColorFilterAddons.brightness(-0.075),
        ColorFilterAddons.contrast(-0.25),
        ColorFilterAddons.saturation(0),
      ]).matrix),
      for (int i = 0; i < filterColors.length; i++)
        ColorFilter.mode(
          filterColors[i],
          BlendMode.softLight,
        ),
    ];
  }

  Widget defaultScreen({Widget? appBar, Function(File)? savedImage}){
    setFilters();
    return EditImage(controller: this, defaultScreen: true, savedImage: savedImage!, appBar: appBar,);
  }

  Widget customScreen({Widget? custom, Function(File)? savedImage}){
    setFilters();
    return EditImage(controller: this, defaultScreen: false, custom: custom!,savedImage: savedImage!,);
  }

  Widget getImageForBackground() {
    switch (imageType) {
      case ImageType.asset:
        return Image.asset(
          src!,
          fit: BoxFit.cover,
        );
      case ImageType.file:
        return Image.file(
          File(src!),
          fit: BoxFit.cover,
        );
      case ImageType.network:
        return Image.network(
          src!,
          fit: BoxFit.cover,
        );
      default:
        return Image.network(
          src!,
          fit: BoxFit.cover,
        );
    }
  }

  Widget getImagePreview() {
    switch (imageType) {
      case ImageType.asset:
        return Image.asset(
          src!,
          fit: BoxFit.cover,
        );
      case ImageType.file:
        return Image.file(
          File(src!),
          fit: BoxFit.cover,
        );
      case ImageType.network:
        return Image.network(
          src!,
          fit: BoxFit.cover,
        );
      default:
        return Container();
    }
  }

  Widget buildImage(dynamic filter, dynamic color){
    return ImageWidget(controller: this, selectedFilter: selectedFilter, selectedColor: selectedColor);
  }
}
