import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care_companion/main.dart';

class PetPhoto extends StatefulWidget {
  final String petid;
  const PetPhoto({super.key, required this.petid});

  @override
  State<PetPhoto> createState() => _PetPhotoState();
}

class _PetPhotoState extends State<PetPhoto> {
  final TextEditingController _title = TextEditingController();
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _uploadedPhotos = [];
  bool _loadingGallery = true;

  @override
  void initState() {
    super.initState();
    _fetchUploadedPhotos();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        File newImage = File(pickedFile.path);
        _photos.add(newImage);
      });
    }
  }

  Future<void> _addPhoto() async {
    try {
      if (_photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a photo first")),
        );
        return;
      }

      String? photoUrl;
      if (_photos.isNotEmpty) {
        photoUrl = await _uploadImage(_photos.last);
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

      setState(() {
        _title.clear();
        _photos.clear();
      });

      await _fetchUploadedPhotos();
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

  Future<void> _fetchUploadedPhotos() async {
    if (widget.petid == null) {
      setState(() {
        _uploadedPhotos = [];
        _loadingGallery = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from('User_tbl_gallery')
          .select('gallery_title, gallery_file, gallery_date')
          .eq('pet_id_id', widget.petid)
          .order('gallery_date', ascending: false);

      setState(() {
        _uploadedPhotos = List<Map<String, dynamic>>.from(response);
        _loadingGallery = false;
      });
    } catch (e) {
      print('Failed to load uploaded photos: $e');
      setState(() {
        _loadingGallery = false;
      });
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
            onPressed: _photos.isNotEmpty ? _addPhoto : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            _photos.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
            const SizedBox(height: 24),
            const Text(
              "Previously Uploaded Photos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _loadingGallery
                ? const Center(child: CircularProgressIndicator())
                : _uploadedPhotos.isEmpty
                    ? const Text(
                        "No photos uploaded yet.",
                        style: TextStyle(color: Colors.grey),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _uploadedPhotos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final photo = _uploadedPhotos[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    photo['gallery_file'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                photo['gallery_title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
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
