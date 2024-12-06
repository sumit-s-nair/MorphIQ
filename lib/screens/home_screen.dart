import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _forms = [];
  bool _isLoading = true;

  // Fetch forms from Firestore
  Future<void> _getUserForms() async {
    try {
      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      // Fetch forms from Firestore collection where the user ID matches
      final formSnapshot = await FirebaseFirestore.instance
          .collection('forms')
          .where('createdBy', isEqualTo: userId)
          .get();

      setState(() {
        _forms = formSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': doc['title'],
                  'createdAt': doc['createdAt'],
                  'fields': doc['fields'],
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching forms: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // Log out function
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserForms();
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        toolbarHeight: 70,
        title: const Row(
          children: [
            Icon(Icons.description, color: Colors.blueAccent, size: 30),
            SizedBox(width: 8),
            Text(
              'MorphIQ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            onSelected: (value) {
              if (value == 'Logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SizedBox(
              width: maxWidth,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'Search forms...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          // Forms Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Forms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Forms List
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _forms.length,
                    itemBuilder: (context, index) {
                      final form = _forms[index];
                      if (_searchQuery.isNotEmpty &&
                          !form['title'].toLowerCase().contains(_searchQuery)) {
                        return const SizedBox();
                      }
                      return _buildFormTile(form);
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.pushNamed(context, '/create-form');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFormTile(Map<String, dynamic> form) {
    return GestureDetector(
      onTap: () {
        // Navigate to form details screen with the form's ID
        Navigator.pushNamed(
          context,
          '/form-details',
          arguments: {
            'id': form['id'],
            'title': form['title'],
            'fields': form['fields'],
          },
        );
      },
      child: Card(
        color: Colors.grey[850],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          title: Text(
            form['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
        ),
      ),
    );
  }
}
