import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Read the original image
  final originalBytes = File('assets/images/LOGO.png').readAsBytesSync();
  final originalImage = img.decodeImage(originalBytes);
  
  if (originalImage == null) {
    print('Failed to decode image');
    return;
  }

  // Calculate new padded size. 
  // Android Adaptive icons recommend the logo to be within the inner 66% of the 108x108 dp area.
  // This means the canvas should be about 1.5x to 1.6x the size of the logo.
  final newWidth = (originalImage.width * 1.6).toInt();
  final newHeight = (originalImage.height * 1.6).toInt();
  
  // Create a new canvas with 3 channels (RGB)
  final paddedImage = img.Image(width: newWidth, height: newHeight, numChannels: 3);
  // Fill with solid maroon color
  img.fill(paddedImage, color: img.ColorRgb8(177, 26, 35));
  
  // Draw the original image centered on the canvas
  final dstX = (newWidth - originalImage.width) ~/ 2;
  final dstY = (newHeight - originalImage.height) ~/ 2;
  
  img.compositeImage(paddedImage, originalImage, dstX: dstX, dstY: dstY);
  
  // Save the padded image
  File('assets/images/LOGO_padded.png').writeAsBytesSync(img.encodePng(paddedImage));
  print('Padded image saved to assets/images/LOGO_padded.png');
}
