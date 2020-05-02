import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:web_upload/apps/main_app.dart';

class FileUploadButton extends StatefulWidget {
  @override
  createState() => _FileUploadButtonState();
}

class _FileUploadButtonState extends State<FileUploadButton> {
  List<int> _selectedFile;
  String display = "hello world";
  Uint8List image;
  var results;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  startWebFilePicker() async {
    html.InputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      final file = files[0];
      final reader = new html.FileReader();

      reader.onLoadEnd.listen((e) {
                    setState(() {
                      image = reader.result;
                    });
        });

        reader.onError.listen((fileEvent) {
          setState(() {
            display = "Some Error occured while reading the file";
          });
        });

        reader.readAsArrayBuffer(file);  
        });
    }    
    
  Future<List<dynamic>> makeRequest() async {
    var url = Uri.parse(
        "http://localhost:3333/predict");
    var request = new http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromBytes('image', image,
        contentType: new MediaType('image', 'jpeg'),
        filename: "image"));
    var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      if (response.statusCode == 200) print("Uploaded!");
      results = json.decode(response.body);
      print(results["predictions"]);
    print('Now what?');
      print(results["predictions"][0]["label"].runtimeType);
      print(results["predictions"].runtimeType);
      return results["predictions"];
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         child: new AlertDialog(
//           title: new Text("Details"),
//           //content: new Text("Hello World"),
//           content: new SingleChildScrollView(
//             child: new ListBody(
//               children: <Widget>[
//                 new Text("Upload successfull"),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             new FlatButton(
//               child: new Text('Aceptar'),
//               onPressed: () {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => UploadApp()),
//                   (Route<dynamic> route) => false,
//                 );
//               },
//             ),
//           ],
//         ));
  }
  
  void _makeRequest() async {
      print("yes?");
      results = await makeRequest();
      print("YES!!!!");
      print(results);
//       display = results;
      print(display);
      setState(() => results = results);
      print('display updated!');
//       return results;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Container(
            child: new Form(
            autovalidate: true,
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 28),
              child: new Container(
                  width: 350,
                  child: Column(children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MaterialButton(
                            color: Colors.pink,
                            hoverColor: Colors.pink[400],
                            elevation: 8,
                            highlightElevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            textColor: Colors.white,
                            child: Text('Select a file'),
                            onPressed: () {
                              startWebFilePicker();
                            },
                          ),
                          Divider(
                            color: Colors.teal,
                          ),
                          RaisedButton(
                            color: Colors.purple,
                            hoverColor: Colors.purple[400],
                            elevation: 8.0,
                            textColor: Colors.white,
                            onPressed: () {
                              _makeRequest();
                            },
                            child: Text('Send file to server'),
                          ),
                         results == null
                          ? Container(
                              child: Text('Hello world'),
                            )
                          : Container(
                              child: Column(
                                  children: [
                                      for ( var i in results ) Text(i["label"].toString())
                                  ],
                              ),
                            )
                        ]),
                  ])),
            ),
          ),
        );
  }
}
