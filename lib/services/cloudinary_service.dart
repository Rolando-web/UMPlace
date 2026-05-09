import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get _apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  static Future<String> uploadImage(XFile image) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Generate signature
    // Cloudinary requires signing: timestamp + api_secret
    final stringToSign = 'timestamp=$timestamp$_apiSecret';
    final bytes = utf8.encode(stringToSign);
    final signature = sha1.convert(bytes).toString();

    final request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = _apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['signature'] = signature;

    final imageBytes = await image.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: image.name.isNotEmpty ? image.name : 'upload.jpg',
      ),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['secure_url'];
    } else {
      throw Exception('Cloudinary Upload Failed: $responseData');
    }
  }
}
