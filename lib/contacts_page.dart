import 'package:flutter/material.dart';
import 'services/contact_service.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final service = ContactService();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      body: FutureBuilder(
        future: service.getContacts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final contacts = snapshot.data as List;

          return ListView(
            children: contacts.map((c) {
              return ListTile(
                title: Text(c['name']),
                subtitle: Text(c['phone']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await service.deleteContact(c['id']);
                    setState(() {});
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await service.addContact(nameCtrl.text, phoneCtrl.text);
          setState(() {});
        },
      ),
    );
  }
}
