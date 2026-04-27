import 'dart:convert';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;
import 'package:gutrgoopro/home/model/category_model.dart';

class CategoryService {

  static Future<List<CategoryModel>> fetchCategories() async {
    try {
      print('🔹 Sending request to ${MyApi.category}'); 
      final response = await http.get(
        Uri.parse('${MyApi.category}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('✅ JSON decoded: $json');

        if (json['success'] == true && json['data'] != null) {
          final List<dynamic> data = json['data'];
          print('🔹 Data length: ${data.length}');
          return data.map((item) => CategoryModel.fromJson(item)).toList();
        } else {
          print('⚠️ No data or success is false');
          return [];
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ CategoryService error: $e');
      throw Exception('CategoryService error: $e');
    }
  }
}