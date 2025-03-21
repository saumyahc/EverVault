import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  _CreateCapsuleScreenState createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientsController = TextEditingController();
  List<String> _selectedFiles = [];
  DateTime? _openDate;

  /// Function to Request Storage Permissions
  Future<bool> _requestPermission() async {
    if (await Permission.storage.isGranted) return true;

    PermissionStatus status = await Permission.storage.request();
    
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required!")),
      );
    }
    return status.isGranted;
  }

  /// Function to Pick Files (Images/Videos)
  Future<void> _pickFiles() async {
    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) {
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'mp4'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = result.paths.whereType<String>().toList();
        });
        debugPrint("Files selected: $_selectedFiles");
      } else {
        debugPrint("No files selected");
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick files. Try again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Capsule"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade900, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(height: 80),
                _buildSectionTitle("Write your message"),
                _buildTextField(_messageController, "Type your message here...", maxLines: 4),
                const SizedBox(height: 20),
                _buildSectionTitle("Add Multimedia"),
                _buildUploadButton(),
                _buildFileList(),
                const SizedBox(height: 20),
                _buildSectionTitle("Add Recipients"),
                _buildTextField(_recipientsController, "Enter recipients' names"),
                const SizedBox(height: 20),
                _buildSectionTitle("Set Opening Date"),
                _buildDatePicker(),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Save Capsule", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: _pickFiles,
      icon: const Icon(Icons.attach_file),
      label: const Text("Upload Images/Videos"),
    );
  }

  Widget _buildFileList() {
    return Column(
      children: _selectedFiles.map((file) {
        return ListTile(
          title: Text(
            file.split('/').last,
            style: const TextStyle(color: Colors.white),
          ),
          leading: const Icon(Icons.file_present, color: Colors.blueAccent),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _openDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _openDate == null
              ? "Select an opening date"
              : "${_openDate!.day}/${_openDate!.month}/${_openDate!.year}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
