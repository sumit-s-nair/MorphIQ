import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitFormPage extends StatefulWidget {
  final String formId;

  const SubmitFormPage({super.key, required this.formId});

  @override
  SubmitFormPageState createState() => SubmitFormPageState();
}

class SubmitFormPageState extends State<SubmitFormPage> {
  late Future<Map<String, dynamic>> _formData;
  final Map<String, dynamic> _responses = {};
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formData = _fetchFormData();
  }

  Future<Map<String, dynamic>> _fetchFormData() async {
    final formRef = FirebaseFirestore.instance.collection('forms').doc(widget.formId);
    final formSnapshot = await formRef.get();
    
    if (formSnapshot.exists) {
      return formSnapshot.data()!;
    } else {
      throw Exception('Form not found');
    }
  }

  // Handle form submission
  Future<void> _submitResponses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to submit the form')));
        return;
      }

      // Save the responses to Firestore
      await FirebaseFirestore.instance.collection('responses').add({
        'formId': widget.formId,
        'userId': user.uid,
        'responses': _responses,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted successfully!')));
      Navigator.pop(context); // Go back after submission
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting form: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Submit Form'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _formData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final form = snapshot.data!;
          final List fields = form['fields'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 8,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gradient Heading
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 23, 193, 98),
                              Color.fromARGB(255, 0, 189, 225)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          form['title'],
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Form fields
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: fields.length,
                          itemBuilder: (context, index) {
                            final field = fields[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildFormField(field),
                            );
                          },
                        ),
                      ),

                      // Submit Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _submitResponses,
                          icon: const Icon(Icons.send),
                          label: const Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Dynamically build form fields based on field type
  Widget _buildFormField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'text':
        return _buildTextField(field);
      case 'mcq':
        return _buildMCQField(field);
      case 'multi_select':
        return _buildMultiSelectField(field);
      case 'date':
        return _buildDateField(field);
      case 'number':
        return _buildNumberField(field);
      default:
        return const SizedBox();
    }
  }

  // Text field
  Widget _buildTextField(Map<String, dynamic> field) {
    return TextField(
      decoration: InputDecoration(
        labelText: field['label'],
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.text_fields, color: Colors.white),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        _responses[field['label']] = value;
      },
    );
  }

  // MCQ (Radio buttons)
  Widget _buildMCQField(Map<String, dynamic> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field['label'], style: const TextStyle(color: Colors.white)),
        ...field['options'].map<Widget>((option) {
          return RadioListTile<String>(
            title: Text(option, style: const TextStyle(color: Colors.white)),
            value: option,
            groupValue: _responses[field['label']],
            onChanged: (value) {
              setState(() {
                _responses[field['label']] = value;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  // Multi-select (Checkboxes)
  Widget _buildMultiSelectField(Map<String, dynamic> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field['label'], style: const TextStyle(color: Colors.white)),
        ...field['options'].map<Widget>((option) {
          return CheckboxListTile(
            title: Text(option, style: const TextStyle(color: Colors.white)),
            value: _responses[field['label']]?.contains(option) ?? false,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  if (_responses[field['label']] == null) {
                    _responses[field['label']] = [];
                  }
                  _responses[field['label']].add(option);
                } else {
                  _responses[field['label']].remove(option);
                }
              });
            },
          );
        }).toList(),
      ],
    );
  }

  // Date input field
  Widget _buildDateField(Map<String, dynamic> field) {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: field['label'],
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          setState(() {
            _dateController.text = selectedDate.toLocal().toString().split(' ')[0]; // Format date as yyyy-mm-dd
            _responses[field['label']] = selectedDate.toString();
          });
        }
      },
      readOnly: true,
    );
  }

  // Number input field
  Widget _buildNumberField(Map<String, dynamic> field) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: field['label'],
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.filter_1, color: Colors.white),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        _responses[field['label']] = int.tryParse(value);
      },
    );
  }
}
