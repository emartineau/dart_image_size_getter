import 'dart:io';

/// {@template image_size_getter.FileUtils}
///
/// [FileUtils] is a class for file operations.
///
/// {@endtemplate}
class FileUtils {
  /// {@macro image_size_getter.FileUtils}
  FileUtils(this.file);

  /// The file.
  File file;

  /// {@macro image_size_getter.FileUtils.getRangeSync}
  Future<List<int>> getRange(int start, int end) async {
    return getRangeSync(start, end);
  }

  /// {@template image_size_getter.FileUtils.getRangeSync}
  ///
  /// Get the range of bytes from [start] to [end].
  ///
  /// {@endtemplate}
  List<int> getRangeSync(int start, int end) {
    final accessFile = file.openSync();
    try {
      accessFile.setPositionSync(start);
      return accessFile.readSync(end - start).toList();
    } finally {
      accessFile.closeSync();
    }
  }
}

/// Gets the length of bytes with trailing null bytes excluded
int trimmedNullsLength(List<int> bytes) {
  int dataLength = bytes.length;
  while (dataLength-- > 0) {
    if (bytes[dataLength - 1] != 0) return dataLength;
  }
  return bytes.length;
}
