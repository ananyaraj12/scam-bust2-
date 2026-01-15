import 'package:shared_preferences/shared_preferences.dart';

class FamilyMember {
  final String name;
  final String phoneNumber;

  FamilyMember({required this.name, required this.phoneNumber});

  Map<String, String> toJson() => {
    'name': name,
    'phoneNumber': phoneNumber,
  };

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}

class FamilyService {
  static const String _familyKey = 'family_members';

  static Future<List<FamilyMember>> getFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final familyList = prefs.getStringList(_familyKey) ?? [];
    
    return familyList.map((json) {
      final map = json.split('|');
      return FamilyMember(name: map[0], phoneNumber: map[1]);
    }).toList();
  }

  static Future<void> addFamilyMember(String name, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final familyList = prefs.getStringList(_familyKey) ?? [];
    familyList.add('$name|$phoneNumber');
    await prefs.setStringList(_familyKey, familyList);
  }

  static Future<void> removeFamilyMember(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final familyList = prefs.getStringList(_familyKey) ?? [];
    if (index >= 0 && index < familyList.length) {
      familyList.removeAt(index);
      await prefs.setStringList(_familyKey, familyList);
    }
  }

  static Future<void> updateFamilyMember(int index, String name, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final familyList = prefs.getStringList(_familyKey) ?? [];
    if (index >= 0 && index < familyList.length) {
      familyList[index] = '$name|$phoneNumber';
      await prefs.setStringList(_familyKey, familyList);
    }
  }
}
