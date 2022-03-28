import 'dart:io';

import 'package:flutter/material.dart';

class AppProvider  {
  //private variables
  File _image;
  bool _isLoading = false;

  // getters
  File get image => this._image;
  bool get isLoading => this._isLoading;

  // saving image to provider
  void updateImage(File image) {
    this._image = image;

  }


  void changeIsLoading(bool isLoading) {
    this._isLoading = isLoading;

  }

}
