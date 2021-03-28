import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

//this app can be used with any image classifer model ,just change the tflite model and the labels in the asset folder and then load your model in loadmodel() method
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs; // stores the outputs from the model
  File _image; // stores the image passed on to the model

  @override
  void initState() {
    super.initState();

    loadModel(); //loading the model once
  }

  pickImage() async {
    final picker = ImagePicker();
    var image = await picker.getImage(
        source: ImageSource
            .gallery); //using imagepicker to choose the image from the gallery
    if (image == null) return null;
    setState(() {
      _image = File(image.path); //storing the image in each state
    });
    classifyImage(File(image.path)); //passing the image to the classifier
  }

  classifyImage(File image) async {
    //storing the output after running the tflite model on the recieved image
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _outputs = output; //storing the outputs in each state
    });
    print(_outputs); //printing the outputs to logs
  }

  loadModel() async {
    //loading the model and the labels
    await Tflite.loadModel(
      model: "assets/cat_dog2.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    //dispose is used to relase the memory allocated to variables
    //when state object is removed
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              //shows CatOrDog as the title of the app
              title: Text(
                "CatOrDog",
              ),
              backgroundColor: Colors.black,
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                // showing the widgets in the center of the app
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // this container will show the preview of the image taken
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: _image != null
                          ? Image.file(
                              _image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Text(
                              "no image",
                              textAlign: TextAlign.center,
                            ),
                      alignment: Alignment.center,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    FlatButton.icon(
                      //this button is pressed when we have to take an image
                      color: Colors.black,
                      icon: Icon(
                        Icons.camera,
                        color: Colors.white,
                      ),
                      label: Text(
                        "take pic",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: pickImage,
                    ),
                    SizedBox(height: 10),
                    _outputs == null
                        ? Text(
                            "no output",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        : Text(
                            "${_outputs[0]["label"]}", //here we are showing the label
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )));
  }
}
