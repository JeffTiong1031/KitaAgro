import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart'; // Run 'flutter pub add uuid' if you don't have this
import 'package:image_picker/image_picker.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection References
  CollectionReference get _postsRef => _db.collection('posts');
  CollectionReference get _usersRef => _db.collection('users');

  // --- 1. UPLOAD IMAGE TO STORAGE ---
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      // Create a unique filename (e.g., "post_images/abc-123.jpg")
      String fileName = const Uuid().v4(); 
      Reference ref = _storage.ref().child('post_images/$fileName.jpg');

      // Upload the file using bytes for web compatibility
      final bytes = await imageFile.readAsBytes();
      UploadTask uploadTask = ref.putData(bytes);
      TaskSnapshot snapshot = await uploadTask;

      // Get the public URL so we can save it to Firestore
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // --- 2. CREATE A NEW POST ---
  Future<void> createPost({
    required String uid,
    required String username, // We pass this to avoid extra reads later
    required String userProfilePic, // Optional: if users have avatars
    required String caption,
    required XFile? imageFile,
  }) async {
    String? imageUrl;

    // If there is an image, upload it first
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
      if (imageUrl == null) return; // Stop if upload failed
    }

    // Save the post data to Firestore
    await _postsRef.add({
      'publisherId': uid,
      'publisherName': username,
      'publisherProfilePic': userProfilePic,
      'caption': caption,
      'imageUrl': imageUrl ?? "", // Empty string if no image
      'likesCount': 0,
      'commentsCount': 0,
      'timestamp': FieldValue.serverTimestamp(), // Server-side time is safest
      'likedBy': [], // List of UIDs who liked this post
    });
  }

  // --- 3. GET POSTS (THE FEED) ---
  Stream<QuerySnapshot> getPostsStream() {
    return _postsRef
        .orderBy('timestamp', descending: true) // Newest first
        .snapshots();
  }

  // --- 4. TOGGLE LIKE ---
  Future<void> toggleLike(String postId, String uid, List likedBy) async {
    if (likedBy.contains(uid)) {
      // Unlike
      await _postsRef.doc(postId).update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([uid]),
      });
    } else {
      // Like
      await _postsRef.doc(postId).update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([uid]),
      });
    }
  }

  // --- 5. DELETE POST ---
  Future<void> deletePost(String postId) async {
    try {
      await _postsRef.doc(postId).delete();
    } catch (e) {
      print("Error deleting post: $e");
    }
  }
}
