import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropconnect/core/theme/app_colors.dart';
import 'package:cropconnect/features/podcasts/domain/model/podcast_model.dart';
import 'package:cropconnect/features/podcasts/presentation/controllers/podcast_controller.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class PodcastPlayerScreen extends GetView<PodcastController> {
  const PodcastPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final podcast = Get.arguments as PodcastModel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentPodcast.value?.id != podcast.id) {
        controller.playPodcast(podcast);
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlbumArt(context, podcast),

                    const SizedBox(height: 24),
                    _buildPodcastInfo(context, podcast),

                    const SizedBox(height: 24),
                    _buildProgressBar(context),
                    const SizedBox(height: 16),
                    _buildPlaybackControls(context),

                    const SizedBox(height: 24),
                    _buildPlaybackOptions(context),

                    // Description
                    const SizedBox(height: 32),
                    _buildDescription(context, podcast),

                    // Tags
                    const SizedBox(height: 24),
                    _buildTags(context, podcast),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          Text(
            "Now Playing",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              // Show options menu
              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.share_rounded),
                        title: Text('Share'),
                        onTap: () {
                          Get.back();
                          // Share functionality
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.download_rounded),
                        title: Text('Download'),
                        onTap: () {
                          Get.back();
                          // Download functionality
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.report_problem_rounded),
                        title: Text('Report issue'),
                        onTap: () {
                          Get.back();
                          // Report functionality
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, PodcastModel podcast) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Obx(() {
          final isCurrentlyPlaying = controller.isPlaying.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: podcast.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  child: Icon(
                    Icons.headphones_rounded,
                    color: theme.colorScheme.onPrimary,
                    size: 72,
                  ),
                ),
              ),

              if (isCurrentlyPlaying)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPodcastInfo(BuildContext context, PodcastModel podcast) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          podcast.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              podcast.author,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${podcast.plays} plays',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Obx(() => TextButton.icon(
                  icon: Icon(
                    controller.isLiked(podcast.id)
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: controller.isLiked(podcast.id) ? Colors.red : null,
                  ),
                  label: Text(
                    '${podcast.likes} likes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: controller.isLiked(podcast.id)
                          ? Colors.red
                          : theme.colorScheme.primary,
                    ),
                  ),
                  onPressed: () => controller.toggleLike(podcast),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Obx(() => ProgressBar(
          progress: controller.currentPosition.value,
          total: controller.totalDuration.value,
          buffered: controller.totalDuration.value,
          progressBarColor: AppColors.primary,
          baseBarColor: Colors.grey.withOpacity(0.2),
          bufferedBarColor: AppColors.primary.withOpacity(0.3),
          thumbColor: AppColors.primary,
          timeLabelTextStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          onSeek: controller.seekTo,
        ));
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.replay_10_rounded, size: 30),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              controller.seekTo(
                Duration(
                  seconds: controller.currentPosition.value.inSeconds - 10,
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.skip_previous_rounded, size: 32),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: controller.playPreviousPodcast,
          ),

          Container(
            width: 64, 
            height: 64, 
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withGreen(AppColors.primary.green + 40),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() => IconButton(
                  icon: Icon(
                    controller.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: controller.togglePlayPause,
                )),
          ),

          IconButton(
            icon: const Icon(Icons.skip_next_rounded, size: 32),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(), 
            onPressed: controller.playNextPodcast,
          ),

          // Skip forward 30 seconds
          IconButton(
            icon: const Icon(Icons.forward_30_rounded, size: 30),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(), 
            onPressed: () {
              controller.seekTo(
                Duration(
                  seconds: controller.currentPosition.value.inSeconds + 30,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackOptions(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Timer',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.speed_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Speed',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.playlist_add_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Playlist',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, PodcastModel podcast) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          podcast.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTags(BuildContext context, PodcastModel podcast) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: podcast.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Get.back();
                  controller.filterByTag(tag);
                  Get.toNamed('/podcasts');
                },
                child: Text(
                  tag,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
