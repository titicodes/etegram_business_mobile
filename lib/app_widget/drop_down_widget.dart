import 'package:flutter/material.dart';

class DropdownWidget extends StatelessWidget {
  final String? value; // Make value nullable
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText; // Hint text parameter
  const DropdownWidget(
      {super.key,
      this.value,
      required this.items,
      required this.onChanged,
      required this.hintText});

  @override
  Widget build(BuildContext context) {
    // Determine the selected value
    String? selectedValue = items.contains(value) ? value : null;

    return Padding(
      padding: EdgeInsets.all(0.0), // Adjust as necessary
      child: Container(
        height: 55.0, // Adjust as necessary
        width: MediaQuery.of(context).size.width, // Use MediaQuery for width
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white, // Adjust to your desired color
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                hintText, // Dynamic hint text
                style: TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontFamily: "Poppins",
                    fontSize: 12),
              ),
            ),
            value: selectedValue,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(item),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down),
            elevation: 0,
            selectedItemBuilder: (BuildContext context) {
              return items.map((String value) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 12), // Adjust as needed
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
