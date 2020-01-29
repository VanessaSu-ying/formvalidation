import 'dart:convert';
import 'dart:io';

import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/preferencias_usuario/preferencias_usuario.dart';

import 'package:http_parser/http_parser.dart';

import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';

class ProductoProvider {
  final String _url = 'https://flutter-varios-ed567.firebaseio.com';

  final _prefs = new PreferenciasUsuario();

  Future<bool> crearProducto(ProductoModel produto) async {
    final url = '$_url/productos.json?auth=${_prefs.token}';

    final resp = await http.post(url, body: productoModelToJson(produto));

    final decodeData = jsonDecode(resp.body);

    print(decodeData);

    return true;
  }

  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/productos.json?auth=${_prefs.token}';
    final resp = await http.get(url);
    final List<ProductoModel> productos = new List();

    Map<String, dynamic> decodeData = jsonDecode(resp.body);

    if (decodeData == null) return [];

    if (decodeData['error'] != null) return [];

    decodeData.forEach((id, prod) {
      final prodTemp = ProductoModel.fromJson(prod);
      prodTemp.id = id;

      productos.add(prodTemp);

      //print(productos[0].titulo);
    });

    return productos;
  }

  Future<int> borrarProducto(String id) async {
    final url = '$_url/productos/$id.json?auth=${_prefs.token}';
    final resp = await http.delete(url);

    print(json.decode(resp.body));

    return 1;
  }

  Future<bool> editarProducto(ProductoModel produto) async {
    final url = '$_url/productos/${produto.id}.json?auth=${_prefs.token}';

    final resp = await http.put(url, body: productoModelToJson(produto));

    final decodeData = jsonDecode(resp.body);

    print(decodeData);

    return true;
  }

  Future<String> subirImagen(File image) async {
    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/dtp9bihaw/image/upload?upload_preset=qd7tuq4v");

    final mimeType = mime(image.path).split('/');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('algo salio mal');
      print(resp.body);

      return null;
    }

    final respData = json.decode(resp.body);
    print(respData);

    return respData['secure_url'];
  }
}
