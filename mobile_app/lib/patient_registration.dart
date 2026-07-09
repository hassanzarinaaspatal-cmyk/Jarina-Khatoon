import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'config/api_config.dart';
import 'services/network_service.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _guardianController = TextEditingController();
  
  String _gender = 'Male';
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  File? _patientPhoto;
  File? _document1;
  File? _document2;
  File? _document3;

  Future<void> _pickImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _patientPhoto = File(picked.path));
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _patientPhoto = File(picked.path));
  }

  Future<void> _pickDocument(int index) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        if (index == 1) _document1 = file;
        else if (index == 2) _document2 = file;
        else if (index == 3) _document3 = file;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    // यहाँ आपकी API सबमिशन लॉजिक है
    await Future.delayed(const Duration(seconds: 2)); 
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("नया मरीज़ रजिस्ट्रेशन"), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "पूरा नाम *", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)), enabled: !_isSaving),
              const SizedBox(height: 12),
              
              Row(children: [
                Expanded(child: TextFormField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "उम्र", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)), enabled: !_isSaving)),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(value: _gender, decoration: const InputDecoration(labelText: "लिंग", border: OutlineInputBorder(), prefixIcon: Icon(Icons.wc)), items: const [DropdownMenuItem(value: 'Male', child: Text('पुरुष')), DropdownMenuItem(value: 'Female', child: Text('महिला')), DropdownMenuItem(value: 'Other', child: Text('अन्य'))], onChanged: _isSaving ? null : (v) => setState(() => _gender = v ?? 'Male'))),
              ]),
              const SizedBox(height: 12),
              
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "मोबाइल नंबर", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), enabled: !_isSaving),
              const SizedBox(height: 12),
              
              TextFormField(controller: _guardianController, decoration: const InputDecoration(labelText: "पिता/पति का नाम", border: OutlineInputBorder(), prefixIcon: Icon(Icons.family_restroom)), enabled: !_isSaving),
              const SizedBox(height: 12),
              
              TextFormField(controller: _addressController, maxLines: 2, decoration: const InputDecoration(labelText: "पता", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)), enabled: !_isSaving),
              const SizedBox(height: 12),
              
              Wrap(spacing: 8, children: [
                ElevatedButton(onPressed: _isSaving ? null : _pickImageFromCamera, child: const Text('Camera')),
                ElevatedButton(onPressed: _isSaving ? null : _pickImageFromGallery, child: const Text('Gallery')),
                ElevatedButton(onPressed: _isSaving ? null : () => _pickDocument(1), child: const Text('Doc 1')),
                ElevatedButton(onPressed: _isSaving ? null : () => _pickDocument(2), child: const Text('Doc 2')),
                ElevatedButton(onPressed: _isSaving ? null : () => _pickDocument(3), child: const Text('Doc 3')),
              ]),
              
              if (_patientPhoto != null) Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Image.file(_patientPhoto!, height: 100)),
              
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_document1 != null) Text("📄 Doc 1 : ${_document1!.path.split('/').last}"),
                if (_document2 != null) Text("📄 Doc 2 : ${_document2!.path.split('/').last}"),
                if (_document3 != null) Text("📄 Doc 3 : ${_document3!.path.split('/').last}"),
              ]),
              
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _isSaving ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("रजिस्टर करें", style: TextStyle(color: Colors.white)))),
              
              const SizedBox(height: 20),
              const Text("Photo और Documents अभी केवल मोबाइल में चुने जा रहे हैं। बाद में इन्हें Server पर भी Save किया जाएगा.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _guardianController.dispose();
    super.dispose();
  }
}
