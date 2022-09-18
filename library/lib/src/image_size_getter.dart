import 'package:image_size_getter/image_size_getter.dart';

export 'core/input.dart';

enum DecoderType { Jpeg, Png, Gif, Webp, Bmp }

/// {@template image_size_getter.ImageSizeGetter}
///
/// The main class of [ImageSizeGetter].
///
/// Simple example:
///
/// ```dart
/// import 'dart:io';
///
/// import 'package:image_size_getter/image_size_getter.dart';
/// import 'package:image_size_getter/file_input.dart'; // For compatibility with flutter web.
///
/// void main(List<String> arguments) async {
///   final file = File('asset/IMG_20180908_080245.jpg');
///   final size = ImageSizeGetter.getSize(FileInput(file));
///   print('jpg size: $size');
/// }
/// ```
///
/// {endtemplate}
class ImageSizeGetter {
  /// The decoders.
  static Map<DecoderType, BaseDecoder> _decoders = {
    DecoderType.Gif: const GifDecoder(),
    DecoderType.Jpeg: const JpegDecoder(),
    DecoderType.Webp: const WebpDecoder(),
    DecoderType.Png: const PngDecoder(),
    DecoderType.Bmp: const BmpDecoder(),
  };

  /// Returns the [input] is png format or not.
  ///
  /// See also: [PngDecoder.isValid] or [PngDecoder.isValidAsync].
  static bool isPng(ImageInput input) {
    return PngDecoder().isValid(input);
  }

  /// Returns the [input] is webp format or not.
  ///
  /// See also: [WebpDecoder.isValid] or [WebpDecoder.isValidAsync].
  static bool isWebp(ImageInput input) {
    return WebpDecoder().isValid(input);
  }

  /// Returns the [input] is gif format or not.
  ///
  /// See also: [GifDecoder.isValid] or [GifDecoder.isValidAsync].
  static bool isGif(ImageInput input) {
    return GifDecoder().isValid(input);
  }

  /// Returns the [input] is jpeg format or not.
  ///
  /// See also: [JpegDecoder.isValid] or [JpegDecoder.isValidAsync].
  static bool isJpg(ImageInput input) {
    return JpegDecoder().isValid(input);
  }

  /// {@template image_size_getter.getSize}
  ///
  /// Get the size of the [input].
  ///
  /// Will check using [suggestedDecoder] first if given
  ///
  /// If the [input] not exists, it will throw [StateError].
  ///
  /// If the [input] is not a valid image format, it will throw [UnsupportedError].
  ///
  /// {@endtemplate}
  static Size getSize(ImageInput input, {DecoderType? suggestedDecoder}) {
    if (!input.exists()) {
      throw StateError('The input is not exists.');
    }
    if (suggestedDecoder != null && _decoders[suggestedDecoder]!.isValid(input)) {
      return _decoders[suggestedDecoder]!.getSize(input);
    }

    for (var decoderType in _decoders.keys) {
      var decoder = _decoders[decoderType]!;
      if (decoder == suggestedDecoder) continue;
      if (decoder.isValid(input)) {
        return decoder.getSize(input);
      }
    }

    throw UnsupportedError('The input is not supported.');
  }

  /// {@macro image_size_getter.getSize}
  ///
  /// The method is async.
  static Future<Size> getSizeAsync(AsyncImageInput input, {DecoderType? suggestedDecoder}) async {
    if (!await input.exists()) {
      throw StateError('The input is not exists.');
    }

    if (!(await input.supportRangeLoad())) {
      final delegateInput = await input.delegateInput();
      try {
        return ImageSizeGetter.getSize(delegateInput);
      } finally {
        delegateInput.release();
      }
    }

    if (suggestedDecoder != null && await _decoders[suggestedDecoder]!.isValidAsync(input)) {
      return _decoders[suggestedDecoder]!.getSizeAsync(input);
    }

    for (var decoderType in _decoders.keys) {
      var decoder = _decoders[decoderType]!;
      if (decoder == suggestedDecoder) continue;
      if (await decoder.isValidAsync(input)) {
        return decoder.getSizeAsync(input);
      }
    }

    throw UnsupportedError('The input is not supported.');
  }
}
