import 'package:flutter/material.dart';
import 'package:scam_burst/localization/translator.dart';
import '../services/family_service.dart';

class FamilyCircleScreen extends StatefulWidget {
  const FamilyCircleScreen({super.key});

  @override
  State<FamilyCircleScreen> createState() => _FamilyCircleScreenState();
}

class _FamilyCircleScreenState extends State<FamilyCircleScreen> {
  late Future<List<FamilyMember>> _familyMembers;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _familyMembers = FamilyService.getFamilyMembers();
  }

  void _showAddDialog({int? index, FamilyMember? member}) {
    if (member != null) {
      _nameController.text = member.name;
      _phoneController.text = member.phoneNumber;
    } else {
      _nameController.clear();
      _phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index != null
            ? Translator.t('edit_family_member')
            : Translator.t('add_family_member')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: Translator.t('name'),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: Translator.t('phone_number'),
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translator.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty) {
                if (index != null) {
                  await FamilyService.updateFamilyMember(
                    index,
                    _nameController.text,
                    _phoneController.text,
                  );
                } else {
                  await FamilyService.addFamilyMember(
                    _nameController.text,
                    _phoneController.text,
                  );
                }
                setState(() {
                  _familyMembers = FamilyService.getFamilyMembers();
                });
                Navigator.pop(context);
              }
            },
            child: Text(
                index != null ? Translator.t('update') : Translator.t('add')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.t('family_circle_title')),
        backgroundColor: Colors.red.shade900,
        elevation: 0,
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _familyMembers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    Translator.t('no_family_members_added'),
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: const Icon(Icons.add),
                    label: Text(Translator.t('add_family_member')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddDialog(),
                  icon: const Icon(Icons.add),
                  label: Text(Translator.t('add_family_member')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade900,
                          child: Text(
                            member.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(member.phoneNumber),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text(Translator.t('edit')),
                              onTap: () =>
                                  _showAddDialog(index: index, member: member),
                            ),
                            PopupMenuItem(
                              child: Text(Translator.t('delete'),
                                  style: const TextStyle(color: Colors.red)),
                              onTap: () async {
                                await FamilyService.removeFamilyMember(index);
                                setState(() {
                                  _familyMembers =
                                      FamilyService.getFamilyMembers();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
