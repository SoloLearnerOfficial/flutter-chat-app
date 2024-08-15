import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  String hintText;
  Size size;
  RegExp validationRegExp;
  bool isObscureText;
  void Function(String?)? onSaved;

  CommonTextField(
      {required this.hintText,
      required this.size,
      required this.validationRegExp,
      required this.onSaved,
      this.isObscureText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.width * 0.01),
      child: TextFormField(
        obscureText: isObscureText,
        onSaved: onSaved,
        validator: (value) {
          if (value.toString().isEmpty) {
            return '${hintText} is empty';
          } else if (validationRegExp.hasMatch(value!)) {
            return null;
          } else {
            return 'Enter a valid ${hintText.toString().toLowerCase()}';
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderSide: BorderSide()),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide()),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide()),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        ),
      ),
    );
  }
}
