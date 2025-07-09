import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.black),
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/home'); // o a donde quieras volver
  },
),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=10'),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 12,
                  child: Icon(Icons.edit, size: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Personal Details'),
            _buildTextField(label: 'Email Address', initialValue: 'aashifa@gmail.com'),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildSectionTitle('Business Address Details'),
            _buildTextField(label: 'Pincode', initialValue: '450016'),
            _buildTextField(label: 'Address', initialValue: '216 St Paul\'s Rd,'),
            _buildTextField(label: 'City', initialValue: 'London'),
            _buildDropdownField(label: 'State', value: 'N1 2LL', items: ['N1 2LL', 'N1 3AX', 'E1 6AN']),
            _buildTextField(label: 'Country', initialValue: 'United Kingdom'),
            const SizedBox(height: 16),
            _buildSectionTitle('Bank Account Details'),
            _buildTextField(label: 'Bank Account Number', initialValue: '204356XXXXXXX'),
            _buildTextField(label: "Account Holder's Name", initialValue: 'Abhiraj Sisodiya'),
            _buildTextField(label: 'IFSC Code', initialValue: 'SBIN000428'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {},
                child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              obscureText: true,
              initialValue: '********',
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Change Password', style: TextStyle(color: Colors.pinkAccent))
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: value,
        onChanged: (String? newValue) {},
        items: items.map<DropdownMenuItem<String>>((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
      ),
    );
  }
}
