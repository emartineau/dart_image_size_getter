import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:image_size_getter/image_size_getter.dart';

/// {@template image_size_getter.WebpDecoder}
///
/// [WebpDecoder] is a class for decoding webp image.
///
/// {@endtemplate}
class WebpDecoder extends BaseDecoder {
  /// {@macro image_size_getter.WebpDecoder}
  const WebpDecoder();

  @override
  String get decoderName => 'webp';

  @override
  Size getSize(ImageInput input) {
    final chunkHeader = input.getRange(12, 16);
    if (_isExtendedFormat(chunkHeader)) {
      final dimensionList = input.getRange(0x18, 0x1d);
      final widthList = dimensionList.sublist(0, 3);
      final heightList = dimensionList.sublist(3, 5);
      return _createExtendedFormatSize(widthList, heightList);
    } else {
      final dimensionList = input.getRange(0x1a, 0x1e);
      final widthList = dimensionList.sublist(0, 2);
      final heightList = dimensionList.sublist(2, 4);
      return _createNormalSize(widthList, heightList);
    }
  }

  Size _createNormalSize(List<int> widthList, List<int> heightList) {
    final width = convertInt16ListToInt(widthList, endianness: Endian.little);
    final height = convertInt16ListToInt(heightList, endianness: Endian.little);
    return Size(width, height);
  }

  Size _createExtendedFormatSize(List<int> widthList, List<int> heightList) {
    final width = convertInt16ListToInt(widthList, endianness: Endian.little) + 1;
    final height = convertInt16ListToInt(heightList, endianness: Endian.little) + 1;
    return Size(width, height);
  }

  bool _isExtendedFormat(List<int> chunkHeader) {
    return ListEquality().equals(chunkHeader, "VP8X".codeUnits);
  }

  @override
  Future<Size> getSizeAsync(AsyncImageInput input) async {
    final chunkHeader = await input.getRange(12, 16);
    if (_isExtendedFormat(chunkHeader)) {
      final dimensionList = await input.getRange(0x18, 0x1d);
      final widthList = dimensionList.sublist(0, 3);
      final heightList = dimensionList.sublist(3, 5);
      return _createExtendedFormatSize(widthList, heightList);
    } else {
      final dimensionList = await input.getRange(0x1a, 0x1e);
      final widthList = dimensionList.sublist(0, 2);
      final heightList = dimensionList.sublist(2, 4);
      return _createNormalSize(widthList, heightList);
    }
  }

  @override
  bool isValid(ImageInput input) {
    final dimensionList = input.getRange(0, 12);
    final sizeStart = dimensionList.sublist(0, 4);
    final sizeEnd = dimensionList.sublist(8, 12);

    const eq = ListEquality();

    if (eq.equals(sizeStart, _WebpHeaders.fileSizeStart) && eq.equals(sizeEnd, _WebpHeaders.fileSizeEnd)) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> isValidAsync(AsyncImageInput input) async {
    final dimensionList = await input.getRange(0, 12);
    final sizeStart = dimensionList.sublist(0, 4);
    final sizeEnd = dimensionList.sublist(8, 12);

    const eq = ListEquality();

    if (eq.equals(sizeStart, _WebpHeaders.fileSizeStart) && eq.equals(sizeEnd, _WebpHeaders.fileSizeEnd)) {
      return true;
    }
    return false;
  }
}

class _WebpHeaders with SimpleFileHeaderAndFooter {
  static const fileSizeStart = [
    0x52,
    0x49,
    0x46,
    0x46,
  ];

  static const fileSizeEnd = [
    0x57,
    0x45,
    0x42,
    0x50,
  ];

  @override
  List<int> get endBytes => fileSizeEnd;

  @override
  List<int> get startBytes => fileSizeStart;
}
