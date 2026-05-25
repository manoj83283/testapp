import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final providerController = TextEditingController();
  final serviceTypeController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();

  String selectedCategory = "birthday";

  File? selectedImage;

  bool isLoading = false;

  final categories = [
    "birthday",
    "wedding",
    "corporate",
    "college",
    "house_party",
    "concert",
    "kids",
    "cultural",
    "outdoor",
  ];

  /// ✅ PICK IMAGE FROM GALLERY
  Future<void> pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  /// ✅ UPLOAD IMAGE TO CLOUDINARY
  Future<String> uploadImage(File imageFile) async {
    final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload");

    final request = http.MultipartRequest('POST', url);

    request.fields["upload_preset"] = "YOUR_UPLOAD_PRESET";

    request.files.add(
      await http.MultipartFile.fromPath("file", imageFile.path),
    );

    final response = await request.send();
    final resString = await response.stream.bytesToString();

    final data = jsonDecode(resString);

    return data["secure_url"];
  }

  /// ✅ SUBMIT SERVICE
  Future<void> submitService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String imageUrl = "";

      /// ✅ upload image if exists
      if (selectedImage != null) {
        imageUrl = await uploadImage(selectedImage!);
      }

      final data = {
        "name": nameController.text.trim(),
        "providerName": providerController.text.trim(),
        "category": selectedCategory,
        "serviceType": serviceTypeController.text.trim(),
        "priceRange": priceController.text.trim(),
        "location": locationController.text.trim(),
        "imageUrl": imageUrl,
      };

      final response = await ApiService.createService(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response["message"] ?? "Service added successfully"),
        ),
      );

      /// ✅ RESET FORM
      _formKey.currentState!.reset();

      setState(() {
        selectedCategory = "birthday";
        selectedImage = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    providerController.dispose();
    serviceTypeController.dispose();
    priceController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Service")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// ✅ IMAGE PICK
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Select Image"),
              ),

              const SizedBox(height: 10),

              if (selectedImage != null)
                Image.file(
                  selectedImage!,
                  height: 120,
                ),

              const SizedBox(height: 12),

              /// ✅ SERVICE NAME
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Service Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter service name" : null,
              ),

              const SizedBox(height: 12),

              /// ✅ PROVIDER NAME
              TextFormField(
                controller: providerController,
                decoration: const InputDecoration(
                  labelText: "Provider Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter provider name" : null,
              ),

              const SizedBox(height: 12),

              /// ✅ CATEGORY
              DropdownButtonFormField(
                value: selectedCategory,
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value.toString();
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              /// ✅ SERVICE TYPE
              TextFormField(
                controller: serviceTypeController,
                decoration: const InputDecoration(
                  labelText: "Service Type",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter service type" : null,
              ),

              const SizedBox(height: 12),

              /// ✅ PRICE
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Price Range",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              /// ✅ LOCATION
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter location" : null,
              ),

              const SizedBox(height: 20),

              /// ✅ SUBMIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitService,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add Service"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}