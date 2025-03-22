import 'dart:async';

import 'package:cropconnect/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:just_audio_background/just_audio_background.dart';
import 'package:cropconnect/features/podcasts/data/services/podcast_service.dart';
import 'package:cropconnect/features/podcasts/domain/model/podcast_model.dart';

class PodcastController extends GetxController {
  final PodcastService _podcastService = Get.find<PodcastService>();
  final AudioPlayer audioPlayer = AudioPlayer();

  final podcasts = <PodcastModel>[].obs;
  final isLoading = true.obs;
  final currentPodcast = Rx<PodcastModel?>(null);
  final isPlaying = false.obs;
  final currentPosition = Duration.zero.obs;
  final totalDuration = Duration.zero.obs;
  final currentTag = ''.obs;
  final downloadProgress = 0.0.obs;
  final likedPodcasts = <String>[].obs;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<List<PodcastModel>>? _podcastSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupPodcastStreams();
    _setupPlayerListeners();
  }

  void _setupPodcastStreams() {
    isLoading.value = true;
    _podcastSubscription = _podcastService.getPodcasts().listen(
      (updatedPodcasts) {
        podcasts.value = updatedPodcasts;
        isLoading.value = false;
        _updateLikeStatus();
      },
      onError: (error) {
        AppLogger.error('Error fetching podcasts: $error');
        isLoading.value = false;
      },
    );
  }

  void _setupPlayerListeners() {
    _positionSubscription = audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
    });

    _playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      if (state.processingState == ProcessingState.completed) {
        playNextPodcast();
      }
    });

    audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });
  }

  Future<void> _updateLikeStatus() async {
    for (var podcast in podcasts) {
      bool liked = await _podcastService.isLiked(podcast.id);
      if (liked && !likedPodcasts.contains(podcast.id)) {
        likedPodcasts.add(podcast.id);
      }
    }
  }

  void filterByTag(String tag) {
    if (tag.isEmpty) {
      _podcastSubscription?.cancel();
      _podcastSubscription = _podcastService.getPodcasts().listen(
        (updatedPodcasts) {
          podcasts.value = updatedPodcasts;
          currentTag.value = '';
        },
      );
    } else {
      isLoading.value = true;
      _podcastSubscription?.cancel();
      _podcastSubscription = _podcastService.getPodcastsByTag(tag).listen(
        (filteredPodcasts) {
          podcasts.value = filteredPodcasts;
          currentTag.value = tag;
          isLoading.value = false;
        },
        onError: (error) {
          AppLogger.error('Error fetching podcasts by tag: $error');
          isLoading.value = false;
        },
      );
    }
  }

  Future<void> playPodcast(PodcastModel podcast) async {
    try {
      downloadProgress.value = 0.0;
      currentPodcast.value = podcast;

      await audioPlayer.stop();
      final audioPath = await _podcastService.getAudioFilePath(podcast);

      // final audioSource = AudioSource.uri(
      //   Uri.parse(audioPath),
      //   tag: MediaItem(
      //     id: podcast.id,
      //     title: podcast.title,
      //     artist: podcast.author,
      //     artUri: Uri.parse(podcast.imageUrl),
      //     duration: Duration(seconds: podcast.duration),
      //   ),
      // );

      // await audioPlayer.setAudioSource(audioSource);
      await audioPlayer.setUrl(audioPath);
      await audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      AppLogger.error('Error playing podcast: $e');
      Get.snackbar('Playback Error', 'Could not play this podcast');
    }
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    isPlaying.value = !isPlaying.value;
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  void playNextPodcast() {
    if (currentPodcast.value == null || podcasts.isEmpty) return;

    final currentIndex =
        podcasts.indexWhere((p) => p.id == currentPodcast.value!.id);
    if (currentIndex < 0 || currentIndex >= podcasts.length - 1) return;

    final nextPodcast = podcasts[currentIndex + 1];
    playPodcast(nextPodcast);
  }

  void playPreviousPodcast() {
    if (currentPodcast.value == null || podcasts.isEmpty) return;

    final currentIndex =
        podcasts.indexWhere((p) => p.id == currentPodcast.value!.id);
    if (currentIndex <= 0) return;

    final previousPodcast = podcasts[currentIndex - 1];
    playPodcast(previousPodcast);
  }

  Future<void> toggleLike(PodcastModel podcast) async {
    final isCurrentlyLiked = likedPodcasts.contains(podcast.id);

    if (isCurrentlyLiked) {
      likedPodcasts.remove(podcast.id);
    } else {
      likedPodcasts.add(podcast.id);
    }

    await _podcastService.toggleLike(podcast, !isCurrentlyLiked);
  }

  bool isLiked(String podcastId) {
    return likedPodcasts.contains(podcastId);
  }

  RxBool isLikedObs(String podcastId) => likedPodcasts.contains(podcastId).obs;

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _podcastSubscription?.cancel();
    audioPlayer.dispose();
    super.onClose();
  }
}
