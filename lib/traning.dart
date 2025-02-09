import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class Training extends StatefulWidget {
  const Training({Key? key}) : super(key: key);

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  List<Map<String, dynamic>> trainingList = [];
  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> breedList = [];

  String? selectedType;
  String? selectedBreed;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchPetTypes();
    fetchTraining();
  }

  // Fetch Training Videos
  Future<void> fetchTraining() async {
    try {
      final response = await supabase.from('Admin_tbl_traning').select();
      setState(() {
        trainingList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching training data: $e');
    }
  }

  // Fetch Pet Types
  Future<void> fetchPetTypes() async {
    try {
      final response = await supabase.from('Admin_tbl_pettype').select();
      setState(() {
        typeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching pet types: $e');
    }
  }

  // Fetch Breeds based on selected Pet Type
  Future<void> fetchBreeds(String typeId) async {
    try {
      final response = await supabase
          .from('Admin_tbl_breed')
          .select()
          .eq('pettype_id', typeId);
      setState(() {
        breedList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching breeds: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Training Videos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Type Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Species',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedType,
              hint: const Text("Select Species"),
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue;
                  selectedBreed = null;
                  breedList.clear();
                });
                if (newValue != null) {
                  fetchBreeds(newValue);
                }
              },
              items: typeList.map((type) {
                return DropdownMenuItem<String>(
                  value: type['id'].toString(),
                  child: Text(type['type_name']),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Breed Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Breed',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedBreed,
              hint: const Text("Select Breed"),
              onChanged: (newValue) {
                setState(() {
                  selectedBreed = newValue;
                });
              },
              items: breedList.map((breed) {
                return DropdownMenuItem<String>(
                  value: breed['id'].toString(),
                  child: Text(breed['breed_name']),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Video List (Filtered)
            Expanded(
              child: ListView.builder(
                itemCount: trainingList.length,
                itemBuilder: (context, index) {
                  final training = trainingList[index];
                  final videoUrl =
                      training['traning_file']; // Video URL from Supabase
                  final trainingBreedId = training['breed_id'].toString();

                  // Get the breed's pet type from the breed list
                  final matchingBreed = breedList.firstWhere(
                    (breed) => breed['id'].toString() == trainingBreedId,
                    orElse: () => {},
                  );

                  final trainingPetTypeId = matchingBreed.isNotEmpty
                      ? matchingBreed['pettype_id'].toString()
                      : null;

                  // Filtering Logic
                  if ((selectedType != null &&
                          trainingPetTypeId != selectedType) ||
                      (selectedBreed != null &&
                          trainingBreedId != selectedBreed)) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            training['traning_name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          VideoPlayerWidget(videoUrl: videoUrl),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}
