import 'package:flutter/material.dart';

class CropModel {
  final String id;
  final String name;
  final IconData icon;
  final List<String> states;

  CropModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.states,
  });

  bool isGrownIn(String state) {
    return states.contains(state);
  }
}
