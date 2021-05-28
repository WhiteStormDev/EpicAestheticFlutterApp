import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/view_models/singup_view_model.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIconData;
  final IconData suffixIconData;
  final bool obscureText;
  final Function onChanged;
  final TextEditingController controller;
  final SignUpViewModel viewModel;

  TextFieldWidget({
    this.viewModel,
    this.controller,
    this.hintText,
    this.prefixIconData,
    this.suffixIconData,
    this.obscureText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      cursorColor: Global.purple,
      style: TextStyle(
        color: Global.purple,
        fontSize: 14.0,
      ),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Global.purple),
        focusColor: Global.purple,
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Global.purple),
        ),
        labelText: hintText,
        prefixIcon: Icon(
          prefixIconData,
          size: 18,
          color: Global.purple,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            viewModel.isVisible = !viewModel.isVisible;
          },
          child: Icon(
            suffixIconData,
            size: 18,
            color: Global.purple,
          ),
        ),
      ),
    );
  }
}