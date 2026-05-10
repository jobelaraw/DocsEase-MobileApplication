import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseServices {
  Future<String?> uploadImageToSupabase(File imageFile, String uid) async {
    try {
      final supabase = Supabase.instance.client;

      // Create a unique file name using the user's UID and the current time
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Upload the file to your 'profile_images' bucket
      await supabase.storage.from('profile_images').upload(fileName, imageFile);

      // Ask Supabase for the public, clickable web link to that image!
      final String publicUrl = supabase.storage.from('profile_images').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print("Supabase Upload Error: $e");
      return null;
    }
  }

  Future<void> deleteOldImage(String oldImageUrl) async {
    try {
      // Safety check: Only proceed if it's an actual Supabase web URL
      if (!oldImageUrl.contains('supabase.co')) return;

      // Extract the actual file name from the end of the URL
      Uri uri = Uri.parse(oldImageUrl);
      String fileName = uri.pathSegments.last; // Grabs the "UID-12345.jpg" part

      // Tell Supabase to remove that specific file
      final supabase = Supabase.instance.client;
      await supabase.storage.from('profile_images').remove([fileName]);

      print("Old image successfully deleted from Supabase!");
    } catch (e) {
      print("Supabase Delete Error: $e");
    }
  }
}
