import 'dart:typed_data';

import 'package:image_size_getter/image_size_getter.dart';

/// {@template image_size_getter.BmpDecoder}
///
/// [BmpDecoder] is a class for decoding BMP file.
///
/// {@endtemplate}
class BmpDecoder extends BaseDecoder {
  /// {@macro image_size_getter.BmpDecoder}
  const BmpDecoder();

  @override
  String get decoderName => 'bmp';

  @override
  Size getSize(ImageInput input) {
    final dimensionList = input.getRange(0x12, 0x1a);
    final widthList = dimensionList.sublist(0, 4);
    final heightList = dimensionList.sublist(4, 8);

    final width = convertInt16ListToInt(widthList, endianness: Endian.little);
    final height = convertInt16ListToInt(heightList, endianness: Endian.little);
    return Size(width, height);
  }

  @override
  Future<Size> getSizeAsync(AsyncImageInput input) async {
    final dimensionList = await input.getRange(0x12, 0x1a);
    final widthList = dimensionList.sublist(0, 4);
    final heightList = dimensionList.sublist(4, 8);

    final width = convertInt16ListToInt(widthList, endianness: Endian.little);
    final height = convertInt16ListToInt(heightList, endianness: Endian.little);
    return Size(width, height);
  }

  @override
  bool isValid(ImageInput input) {
    final list = input.getRange(0, 2);
    return _isBmp(list);
  }

  @override
  Future<bool> isValidAsync(AsyncImageInput input) async {
    final list = await input.getRange(0, 2);
    return _isBmp(list);
  }

  bool _isBmp(List<int> startList) {
    return startList[0] == 66 && startList[1] == 77;
  }
}
