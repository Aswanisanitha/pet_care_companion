import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetGalleryScreen extends StatefulWidget {
  final String petId;

  const PetGalleryScreen({super.key, required this.petId});

  @override
  State<PetGalleryScreen> createState() => _PetGalleryScreenState();
}

class _PetGalleryScreenState extends State<PetGalleryScreen> {
  final supabase = Supabase.instance.client;
  List<String> galleryUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGalleryImages();
  }

  Future<void> fetchGalleryImages() async {
    try {
      final response = await supabase
          .from('User_tbl_gallery')
          .select()
          .eq('pet_id_id', widget.petId);

      setState(() {
        galleryUrls = List<Map<String, dynamic>>.from(response)
            .map((img) => img['gallery_file'] as String)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching gallery: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Gallery'),
        backgroundColor: Colors.deepOrange.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : galleryUrls.isEmpty
              ? const Center(child: Text('No images found for this pet.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: galleryUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        galleryUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      ),
                    );
                  },
                ),
    );
  }
}
