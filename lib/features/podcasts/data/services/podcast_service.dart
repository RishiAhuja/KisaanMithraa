import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/core/services/hive/hive_storage_service.dart';
import 'package:cropconnect/utils/app_logger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cropconnect/features/podcasts/domain/model/podcast_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PodcastService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Map<String, String> _cachedAudioFiles = {};
  final Map<String, DateTime> _cacheExpiryTimes = {};
  final Duration _cacheDuration = const Duration(days: 7);

  Future<PodcastService> init() async {
    await _loadCachedFilesInfo();
    return this;
  }

  Future<void> _loadCachedFilesInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUrls = prefs.getStringList('podcast_cached_urls') ?? [];
      final cachedPaths = prefs.getStringList('podcast_cached_paths') ?? [];
      final cachedExpiry = prefs.getStringList('podcast_cache_expiry') ?? [];

      if (cachedUrls.length == cachedPaths.length &&
          cachedUrls.length == cachedExpiry.length) {
        for (int i = 0; i < cachedUrls.length; i++) {
          _cachedAudioFiles[cachedUrls[i]] = cachedPaths[i];
          _cacheExpiryTimes[cachedUrls[i]] = DateTime.parse(cachedExpiry[i]);
        }
      }

      await cleanExpiredCache();
    } catch (e) {
      AppLogger.error('Error loading cached files info: $e');
    }
  }

  Future<void> _saveCachedFilesInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          'podcast_cached_urls', _cachedAudioFiles.keys.toList());
      prefs.setStringList(
          'podcast_cached_paths', _cachedAudioFiles.values.toList());
      prefs.setStringList('podcast_cache_expiry',
          _cacheExpiryTimes.values.map((dt) => dt.toIso8601String()).toList());
    } catch (e) {
      AppLogger.error('Error saving cached files info: $e');
    }
  }

  Future<void> cleanExpiredCache() async {
    final now = DateTime.now();
    final expiredUrls = <String>[];

    _cacheExpiryTimes.forEach((url, expiry) {
      if (now.isAfter(expiry)) {
        expiredUrls.add(url);
      }
    });

    for (var url in expiredUrls) {
      final path = _cachedAudioFiles[url];
      if (path != null) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
          _cachedAudioFiles.remove(url);
          _cacheExpiryTimes.remove(url);
        } catch (e) {
          AppLogger.error('Error cleaning expired cache for $url: $e');
        }
      }
    }

    await _saveCachedFilesInfo();
  }

  Stream<List<PodcastModel>> getPodcasts() {
    return _firestore
        .collection('podcasts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PodcastModel.fromFirestore(doc, null))
            .toList());
  }

  Stream<List<PodcastModel>> getPodcastsByTag(String tag) {
    return _firestore
        .collection('podcasts')
        .where('tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PodcastModel.fromFirestore(doc, null))
            .toList());
  }

  Future<String> getAudioFilePath(PodcastModel podcast) async {
    if (_cachedAudioFiles.containsKey(podcast.audioUrl)) {
      final path = _cachedAudioFiles[podcast.audioUrl]!;
      final file = File(path);

      if (await file.exists()) {
        final expiry = _cacheExpiryTimes[podcast.audioUrl];
        if (expiry != null && expiry.isAfter(DateTime.now())) {
          return path;
        }
      }
    }

    return await _downloadAndCacheAudio(podcast);
  }

  Future<String> _downloadAndCacheAudio(PodcastModel podcast) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'podcast_${podcast.id}.mp3';
      final file = File('${appDir.path}/podcasts/$fileName');

      await Directory('${appDir.path}/podcasts').create(recursive: true);

      AppLogger.debug('Downloading podcast: ${podcast.title}');

      if (podcast.audioUrl.startsWith('gs://')) {
        final ref = _storage.refFromURL(podcast.audioUrl);
        await ref.writeToFile(file);
      } else {
        final response = await http.get(Uri.parse(podcast.audioUrl));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception(
              'Failed to download audio file: ${response.statusCode}');
        }
      }

      _cachedAudioFiles[podcast.audioUrl] = file.path;
      _cacheExpiryTimes[podcast.audioUrl] = DateTime.now().add(_cacheDuration);
      await _saveCachedFilesInfo();

      await _recordPlay(podcast);

      return file.path;
    } catch (e) {
      AppLogger.error('Error downloading podcast: $e');
      return podcast.audioUrl;
    }
  }

  Future<void> _recordPlay(PodcastModel podcast) async {
    try {
      await _firestore.collection('podcasts').doc(podcast.id).update({
        'plays': FieldValue.increment(1),
      });
    } catch (e) {
      AppLogger.error('Error recording play: $e');
    }
  }

  Future<void> toggleLike(PodcastModel podcast, bool liked) async {
    try {
      final docRef = _firestore.collection('podcasts').doc(podcast.id);

      await docRef.update({
        'likes': FieldValue.increment(liked ? 1 : -1),
      });

      final userService = Get.find<UserStorageService>();
      final user = await userService.getUser();
      final userId = user?.id;
      if (userId != null) {
        final likeRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('podcast_likes')
            .doc(podcast.id);

        if (liked) {
          await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
        } else {
          await likeRef.delete();
        }
      }
    } catch (e) {
      AppLogger.error('Error toggling like: $e');
    }
  }

  Future<bool> isLiked(String podcastId) async {
    try {
      final userService = Get.find<UserStorageService>();
      final user = await userService.getUser();
      final userId = user?.id;
      if (userId == null) return false;

      final likeDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('podcast_likes')
          .doc(podcastId)
          .get();

      return likeDoc.exists;
    } catch (e) {
      AppLogger.error('Error checking if podcast is liked: $e');
      return false;
    }
  }

  Future<void> clearCache() async {
    try {
      for (var path in _cachedAudioFiles.values) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _cachedAudioFiles.clear();
      _cacheExpiryTimes.clear();
      await _saveCachedFilesInfo();
    } catch (e) {
      AppLogger.error('Error clearing cache: $e');
    }
  }
}
