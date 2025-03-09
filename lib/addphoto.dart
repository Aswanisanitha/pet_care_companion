import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care_companion/main.dart';

class petphoto extends StatefulWidget {
  final String? petid;
  const petphoto({super.key, this.petid});

  @override
  State<petphoto> createState() => _petphotoState();
}

class _petphotoState extends State<petphoto> {
  final TextEditingController _title = TextEditingController();
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        File newImage = File(pickedFile.path);
        _photos.add(newImage); // Add to photos list for display
      });
    }
  }

  Future<void> _addphoto() async {
    try {
      if (_photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a photo first")),
        );
        return;
      }

      String? photoUrl;
      if (_photos.isNotEmpty) {
        photoUrl =
            await _uploadImage(_photos.last); // Upload the most recent photo
      }

      await supabase.from('User_tbl_gallery').insert({
        'pet_id_id': widget.petid,
        'gallery_title': _title.text,
        'gallery_file': photoUrl,
        'gallery_date': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully Added")),
      );

      // Optionally clear the form after successful upload
      setState(() {
        _title.clear();
        _photos.clear();
      });
    } catch (e) {
      print('Pet photo not added: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add photo: $e")),
      );
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final folderName = "PetDocs";
      // Use timestamp to ensure unique filename
      final fileName =
          "$folderName/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}";

      await supabase.storage.from('petcare').upload(fileName, image);

      final imageUrl = supabase.storage.from('petcare').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Add Pet Photo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _photos.isNotEmpty ? _addphoto : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.deepOrange.shade900),
                hintText: "Enter the title",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                ),
                prefixIcon:
                    Icon(Icons.title, color: Colors.deepOrange.shade900),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.photo, color: Colors.white),
                label: const Text(
                  "Upload Photo",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _photos.isNotEmpty
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _photos[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No photos selected yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }
}
