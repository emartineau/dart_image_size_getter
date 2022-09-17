import 'package:image_size_getter/image_size_getter.dart';

/// {@template image_size_getter.GifDecoder}
///
/// [GifDecoder] is a class for decoding gif image.
///
/// {@endtemplate}
class GifDecoder extends BaseDecoder with MutilFileHeaderAndFooterValidator {
  /// {@macro image_size_getter.GifDecoder}
  const GifDecoder();

  String get decoderName => 'gif';

  Size _getSize(List<int> widthList, List<int> heightList) {
    final width = convertInt16ListToInt(widthList, reverse: true);
    final height = convertInt16ListToInt(heightList, reverse: true);

    return Size(width, height);
  }

  @override
  Size getSize(ImageInput input) {
    final dimensionList = input.getRange(6, 10);
    assert(dimensionList.length == 4);
    final widthList = dimensionList.sublist(0, 2);
    final heightList = dimensionList.sublist(2, 4);

    return _getSize(widthList, heightList);
  }

  @override
  Future<Size> getSizeAsync(AsyncImageInput input) async {
    final widthList = await input.getRange(6, 8);
    final heightList = await input.getRange(8, 10);

    return _getSize(widthList, heightList);
  }

  @override
  MutilFileHeaderAndFooter get headerAndFooter => _GifInfo();
}

class _GifInfo with MutilFileHeaderAndFooter {
  static const start89a = [
    0x47,
    0x49,
    0x46,
    0x38,
    0x37,
    0x61,
  ];
  static const start87a = [
    0x47,
    0x49,
    0x46,
    0x38,
    0x39,
    0x61,
  ];

  static const end = [0x3B];

  @override
  List<List<int>> get mutipleEndBytesList => [end];

  @override
  List<List<int>> get mutipleStartBytesList => [
        start87a,
        start89a,
      ];
}
