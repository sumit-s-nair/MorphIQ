import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'create_form_screen.dart';

class FormDetailsPage extends StatefulWidget {
  const FormDetailsPage({super.key});

  @override
  FormDetailsPageState createState() => FormDetailsPageState();
}

class FormDetailsPageState extends State<FormDetailsPage>
    with SingleTickerProviderStateMixin {
  late final String formId;
  late final String formTitle;
  late final List<Map<String, dynamic>> formFields;
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Two tabs: Form and Responses
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    formId = args['id'];
    formTitle = args['title'];
    formFields = List<Map<String, dynamic>>.from(args['fields']);
  }

  Future<void> _deleteForm() async {
    try {
      await _firestore.collection('forms').doc(formId).delete();
      await _firestore.collection('responses').doc(formId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form deleted successfully')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting form: $e')),
        );
      }
    }
  }

  void _shareForm() {
    final String formLink = "https://morph-iq.vercel.app/#/forms/$formId";
    Clipboard.setData(ClipboardData(text: formLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form link copied to clipboard')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(formTitle, style: const TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateFormPage(
                    form: {
                      'id': formId,
                      'title': formTitle,
                      'fields': formFields,
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.blueAccent),
            onPressed: _shareForm,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _deleteForm,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Form'),
            Tab(icon: Icon(Icons.visibility), text: 'Responses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormDetails(),
          _buildResponses(),
        ],
      ),
    );
  }

  Widget _buildFormDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Form Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: formFields.length,
              itemBuilder: (context, index) {
                final field = formFields[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildFormField(field),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'text':
        return _buildTextDisplay(field);
      case 'mcq':
        return _buildMCQDisplay(field);
      case 'multi_select':
        return _buildMultiSelectDisplay(field);
      case 'date':
        return _buildDateDisplay(field);
      case 'number':
        return _buildNumberDisplay(field);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextDisplay(Map<String, dynamic> field) {
    return Card(
      color: Colors.grey[850],
      child: ListTile(
        title:
            Text(field['label'], style: const TextStyle(color: Colors.white)),
        subtitle:
            const Text('Type: Text', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildMCQDisplay(Map<String, dynamic> field) {
    return Card(
      color: Colors.grey[850],
      child: ListTile(
        title:
            Text(field['label'], style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: field['options'].map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child:
                  Text('- $option', style: const TextStyle(color: Colors.grey)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMultiSelectDisplay(Map<String, dynamic> field) {
    return Card(
      color: Colors.grey[850],
      child: ListTile(
        title:
            Text(field['label'], style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: field['options'].map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child:
                  Text('- $option', style: const TextStyle(color: Colors.grey)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateDisplay(Map<String, dynamic> field) {
    return Card(
      color: Colors.grey[850],
      child: ListTile(
        title:
            Text(field['label'], style: const TextStyle(color: Colors.white)),
        subtitle:
            const Text('Type: Date', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildNumberDisplay(Map<String, dynamic> field) {
    return Card(
      color: Colors.grey[850],
      child: ListTile(
        title:
            Text(field['label'], style: const TextStyle(color: Colors.white)),
        subtitle:
            const Text('Type: Number', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildResponses() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('responses')
          .where('formId', isEqualTo: formId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading responses: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No responses yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final responses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: responses.length,
          itemBuilder: (context, index) {
            final response = responses[index];
            final Map<String, dynamic> answers =
                response.data() as Map<String, dynamic>;

            final responseDetails = answers['responses'] ?? {};
            final submissionTime = answers['submittedAt'] is Timestamp
                ? (answers['submittedAt'] as Timestamp).toDate()
                : null;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Response Header
                    Text(
                      'Response #${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Submission Time
                    if (submissionTime != null)
                      Text(
                        'Submitted at: ${submissionTime.toString()}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),

                    const Divider(color: Colors.grey),

                    // Response Content
                    ...responseDetails.entries.map((entry) {
                      String key = entry.key;
                      dynamic value = entry.value;

                      // Format Timestamp to readable date string
                      if (value is Timestamp) {
                        value = value.toDate().toString();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Key (Label)
                            Expanded(
                              flex: 2,
                              child: Text(
                                key,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Value
                            Expanded(
                              flex: 3,
                              child: Text(
                                value.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
