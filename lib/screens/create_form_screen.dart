import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'form_field_options.dart';

class CreateFormPage extends StatefulWidget {
  const CreateFormPage({super.key});

  @override
  CreateFormPageState createState() => CreateFormPageState();
}

class CreateFormPageState extends State<CreateFormPage> {
  List<Map<String, dynamic>> formFields = [];
  TextEditingController formNameController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addField(String fieldType) {
    setState(() {
      // Initialize options for specific field types
      List<String>? options =
          (fieldType == 'mcq' || fieldType == 'multi_select') ? [''] : null;

      // Create the new field map
      Map<String, dynamic> newField = {
        'type': fieldType,
        'label': '${fieldType.capitalize()} Field',
        'options': options,
      };

      // Add the new field to the list
      formFields.add(newField);

      // Update the 'input' key after the field is added
      int newIndex = formFields.length - 1;
      formFields[newIndex]['input'] = buildFieldInput(
        fieldType,
        (updatedOptions) {
          // Update the options of the correct field
          setState(() {
            formFields[newIndex]['options'] = updatedOptions;
          });
        },
      );
    });
  }

  void _createForm() async {
    User? user = FirebaseAuth.instance.currentUser;
    // Create the form structure to save to Firestore
    final formData = {
      'title': formNameController.text,
      'createdBy': user?.uid ?? 'guest',
      'createdAt': FieldValue.serverTimestamp(),
      'fields': formFields.map((field) {
        return {
          'type': field['type'],
          'label': field['label'],
          'options': field['options'],
        };
      }).toList(),
    };

    try {
      // Add the form to Firestore
      await _firestore.collection('forms').add(formData);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating form: $e')),
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
        title: const Text('Create Form', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blueAccent),
            onPressed: _createForm, // Trigger form creation
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
                  child: ReorderableListView(
                    onReorder: _onReorder,
                    children: [
                      for (int index = 0; index < formFields.length; index++)
                        Card(
                          key: ValueKey(index),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () {
                                    _showLabelEditor(index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteField(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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

  void _deleteField(int index) {
    setState(() {
      formFields.removeAt(index);
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
