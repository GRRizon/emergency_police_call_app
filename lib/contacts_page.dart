import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Trusted Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _saveContact,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      return;
    }

    try {
      final userId = supabase.auth.currentUser?.id;
      await supabase.from('emergency_contacts').insert({
        'user_id': userId,
        'name': name,
        'phone_number': phone,
      });

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      _nameController.clear();
      _phoneController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact saved successfully!")),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              color: Color(0xFFFFF5F5),
              child: ListTile(
                leading: Icon(Icons.shield, color: Colors.blue),
                title: Text("Police Hotline",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("999 / 911"),
                trailing: Icon(Icons.call, color: Colors.green),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('emergency_contacts')
                  .stream(primaryKey: ['id']).order('created_at'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading contacts."));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final contacts = snapshot.data!;
                if (contacts.isEmpty) {
                  return const Center(child: Text("No trusted contacts yet."));
                }

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(contact['name']),
                        subtitle: Text(contact['phone_number']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await supabase
                                .from('emergency_contacts')
                                .delete()
                                .match({'id': contact['id']});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _showAddContactDialog,
                icon: const Icon(Icons.add, color: Colors.red),
                label: const Text("Add Trusted Contact",
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFE0E0)),
                  backgroundColor: const Color(0xFFFFF8F8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
