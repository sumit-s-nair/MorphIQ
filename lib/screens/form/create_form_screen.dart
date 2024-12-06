import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morph_iq/screens/form_field_options.dart'; // Import field types

class CreateFormPage extends StatefulWidget {
  final Map<String, dynamic> form;
  const CreateFormPage({super.key, required this.form});

  @override
  CreateFormPageState createState() => CreateFormPageState();
}

class CreateFormPageState extends State<CreateFormPage> {
  List<Map<String, dynamic>> formFields = [];
  TextEditingController formNameController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize form fields and title from the passed form data
    formFields = List<Map<String, dynamic>>.from(widget.form['fields']);
    formNameController.text = widget.form['title'];
  }

  void _addField(String fieldType) {
    setState(() {
      void onOptionsChanged(List<String> options) {
        int index =
            formFields.indexWhere((field) => field['type'] == fieldType);
        if (index != -1) {
          setState(() {
            formFields[index]['options'] = options;
          });
        }
      }

      Map<String, dynamic> newField = {
        'type': fieldType,
        'label': '${fieldType.capitalize()} Field',
        'input': buildFieldInput(fieldType, onOptionsChanged),
        'options':
            (fieldType == 'mcq' || fieldType == 'multi_select') ? [''] : null,
      };

      if (fieldType == 'mcq' || fieldType == 'multi_select') {
        newField['options'] = [''];
      }

      formFields.add(newField);
    });
  }

  void _updateForm() async {
    // Update the form structure in Firestore
    final formData = {
      'title': formNameController.text,
      'fields': formFields.map((field) {
        return {
          'type': field['type'],
          'label': field['label'],
          'options': field['options'],
        };
      }).toList(),
    };

    try {
      // Update the form in Firestore
      await _firestore
          .collection('forms')
          .doc(widget.form['id'])
          .update(formData);

      // Navigate back to the previous screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: const Text('Edit Form', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blueAccent),
            onPressed: _updateForm,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 23, 193, 98),
                        Color.fromARGB(255, 0, 189, 225)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Form Name',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: formNameController,
                        decoration: InputDecoration(
                          labelText: 'Enter Form Name',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Give your form a title',
                          hintStyle: const TextStyle(color: Colors.white60),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: formFields.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.drag_handle,
                              color: Colors.blueAccent),
                          title: Text(
                            formFields[index]['label'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: formFields[index]['input'],
                          trailing: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent),
                            onPressed: () {
                              _showLabelEditor(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FloatingActionButton(
                  onPressed: () => _showFieldOptions(context),
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = formFields.removeAt(oldIndex);
      formFields.insert(newIndex, item);
    });
  }

  void _showFieldOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var fieldType in fieldTypes)
                ListTile(
                  leading: Icon(fieldType['icon']),
                  title: Text(fieldType['label']),
                  onTap: () {
                    Navigator.pop(context);
                    _addField(fieldType['type']);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showLabelEditor(int index) {
    final TextEditingController controller =
        TextEditingController(text: formFields[index]['label']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Field Label'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Field Label',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  formFields[index]['label'] = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
