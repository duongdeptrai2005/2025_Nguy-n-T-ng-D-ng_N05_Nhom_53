import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 🌥️ Service upload ảnh lên Cloudinary (dạng unsigned)
class CloudinaryService {
  // 🔁 Thay bằng giá trị thật của bạn
  static const String cloudName = 'daroezcos'; // 👈 cloud name thật
  static const String uploadPreset = 'flutter_upload'; // 👈 preset đã tạo trong Cloudinary

  /// Upload ảnh lên Cloudinary và trả về URL online
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      if (response.statusCode == 200) {
        print("✅ Upload thành công: ${data['secure_url']}");
        return data['secure_url']; // URL ảnh online
      } else {
        print("❌ Upload thất bại: ${data['error']}");
        return null;
      }
    } catch (e) {
      print("⚠️ Lỗi upload Cloudinary: $e");
      return null;
    }
  }
}
