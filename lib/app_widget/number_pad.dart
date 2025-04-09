// number_pad.dart

import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onDonePressed;

  const NumberPad({super.key, required this.onDigitPressed, required this.onDonePressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: buildDigitButton('1')),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDigitButton('2')),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDigitButton('3')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: buildDigitButton('4')),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDigitButton('5')),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDigitButton('6')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: buildDigitButton('7')),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDigitButton('8')),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDigitButton('9')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: buildSuccessButton()),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDigitButton('0')),
              const SizedBox(
                width: 3,
              ),
              Expanded(child: buildDeleteButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSuccessButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      // width: 105,
      height: 45,
      // decoration: BoxDecoration(
      //   shape: BoxShape.circle,
      //   color: Colors.grey,
      // ),
      child: ElevatedButton(
          onPressed: () {
            // onDonePressed(); // Fix: Add parentheses to invoke the callback
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          child: const Text("")),
    );
  }

  Widget buildDigitButton(String digit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      //width: 105,
      height: 45,
      // decoration: BoxDecoration(
      //   shape: BoxShape.circle,
      //   color: Colors.grey,
      // ),
      child: ElevatedButton(
        onPressed: () => onDigitPressed(digit),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        child: Text(
          digit,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget buildDeleteButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      // width: 105,
      height: 45,
      // decoration: BoxDecoration(
      //   shape: BoxShape.circle,
      //   color: Colors.grey,
      // ),
      child: ElevatedButton(
        onPressed: () => onDigitPressed('delete'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        child: const Icon(
          Icons.backspace,
          color: Colors.black,
        ),
      ),
    );
  }
}
