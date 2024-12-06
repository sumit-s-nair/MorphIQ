import 'package:flutter/material.dart';

// List of available field types and their labels/icons
final List<Map<String, dynamic>> fieldTypes = [
  {
    'type': 'text',
    'label': 'Text Input',
    'icon': Icons.text_fields,
  },
  {
    'type': 'mcq',
    'label': 'Multiple Choice (MCQ)',
    'icon': Icons.radio_button_checked,
  },
  {
    'type': 'date',
    'label': 'Date Input',
    'icon': Icons.date_range,
  },
  {
    'type': 'number',
    'label': 'Number Input',
    'icon': Icons.format_list_numbered,
  },
  {
    'type': 'multi_select',
    'label': 'Multi Select',
    'icon': Icons.check_box,
  },
];

// Input widget for the respective field types
Widget buildFieldInput(String fieldType, void Function(List<String>) onOptionsChanged) {
  switch (fieldType) {
    case 'text':
      return const TextField(
        decoration: InputDecoration(
          labelText: 'Enter text',
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      );
    case 'mcq':
      return MCQField(onOptionsChanged: onOptionsChanged);  // Pass onOptionsChanged here
    case 'date':
      return const DatePickerField();
    case 'number':
      return const CountryCodeNumberField();
    case 'multi_select':
      return MultiSelectField(onOptionsChanged: onOptionsChanged); // Pass onOptionsChanged here
    default:
      return Container();
  }
}

// MCQ Field
class MCQField extends StatefulWidget {
  final ValueChanged<List<String>> onOptionsChanged;

  const MCQField({super.key, required this.onOptionsChanged});

  @override
  MCQFieldState createState() => MCQFieldState();
}

class MCQFieldState extends State<MCQField> {
  List<TextEditingController> controllers = [];

  void _addField() {
    setState(() {
      controllers.add(TextEditingController());
    });
    widget.onOptionsChanged(controllers.map((controller) => controller.text).toList());
  }

  void _removeField(int index) {
    if (controllers.isNotEmpty) {
      setState(() {
        controllers.removeAt(index);
      });
    }
    widget.onOptionsChanged(controllers.map((controller) => controller.text).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MCQ Options:'),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    onChanged: (_) {
                      widget.onOptionsChanged(
                        controllers.map((controller) => controller.text).toList(),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeField(index),
                ),
              ],
            ),
          );
        }),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.blue),
          onPressed: _addField,
        ),
      ],
    );
  }
}

// Multi Select Field
class MultiSelectField extends StatefulWidget {
  final ValueChanged<List<String>> onOptionsChanged;

  const MultiSelectField({super.key, required this.onOptionsChanged});

  @override
  MultiSelectFieldState createState() => MultiSelectFieldState();
}

class MultiSelectFieldState extends State<MultiSelectField> {
  List<TextEditingController> controllers = [];

  void _addField() {
    setState(() {
      controllers.add(TextEditingController());
    });
    widget.onOptionsChanged(controllers.map((controller) => controller.text).toList());
  }

  void _removeField(int index) {
    if (controllers.isNotEmpty) {
      setState(() {
        controllers.removeAt(index);
      });
    }
    widget.onOptionsChanged(controllers.map((controller) => controller.text).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Multi Select Options:'),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    onChanged: (_) {
                      widget.onOptionsChanged(
                        controllers.map((controller) => controller.text).toList(),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeField(index),
                ),
              ],
            ),
          );
        }),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.blue),
          onPressed: _addField,
        ),
      ],
    );
  }
}

// Custom Widget for the Date Picker
class DatePickerField extends StatefulWidget {
  const DatePickerField({super.key});

  @override
  DatePickerFieldState createState() => DatePickerFieldState();
}

class DatePickerFieldState extends State<DatePickerField> {
  TextEditingController controller = TextEditingController();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Select Date',
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        hintText: 'Select a date',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
          onPressed: () => _pickDate(context),
        ),
      ),
    );
  }
}

// Custom Widget for the Number Input with Country Code
class CountryCodeNumberField extends StatefulWidget {
  const CountryCodeNumberField({super.key});

  @override
  CountryCodeNumberFieldState createState() => CountryCodeNumberFieldState();
}

class CountryCodeNumberFieldState extends State<CountryCodeNumberField> {
  String _selectedCountryCode = '+91';
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          value: _selectedCountryCode,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Colors.blueAccent),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCountryCode = newValue!;
            });
          },
          items: <String>['+1', '+44', '+91', '+61', '+33']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter a number',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              hintText: 'Enter your number',
            ),
          ),
        ),
      ],
    );
  }
}
