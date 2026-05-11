import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/provider_service.dart';
import '../models/provider_model.dart';

class ProviderProfileEditScreen extends StatefulWidget {
  final String token;
  const ProviderProfileEditScreen({required this.token, super.key});

  @override
  State<ProviderProfileEditScreen> createState() => _ProviderProfileEditScreenState();
}

class _ProviderProfileEditScreenState extends State<ProviderProfileEditScreen> {
  final _descController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _priceHourController = TextEditingController();
  final _priceDayController = TextEditingController();
  final _ratingController = TextEditingController();

  List<File> photos = [];
  List<File> videos = [];
  bool loading = false;

  Future<void> _pickMedia(bool isPhoto) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        photos.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _uploadProfile() async {
    setState(() => loading = true);
    try {
      final updated = await ProviderService().updateProfile(
        token: widget.token,
        description: _descController.text,
        rating: double.tryParse(_ratingController.text) ?? 0,
        pricePerHour: double.tryParse(_priceHourController.text) ?? 0,
        pricePerDay: double.tryParse(_priceDayController.text) ?? 0,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        photos: photos,
        videos: videos,
      );
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context, updated);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _ratingController, decoration: const InputDecoration(labelText: 'Rating')),
          TextField(controller: _priceHourController, decoration: const InputDecoration(labelText: 'Price per Hour')),
          TextField(controller: _priceDayController, decoration: const InputDecoration(labelText: 'Price per Day')),
          TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
          TextField(controller: _stateController, decoration: const InputDecoration(labelText: 'State')),
          TextField(controller: _countryController, decoration: const InputDecoration(labelText: 'Country')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => _pickMedia(true), child: const Text('Pick Photos')),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _uploadProfile, child: loading ? const CircularProgressIndicator() : const Text('Upload Profile')),
        ]),
      ),
    );
  }
}