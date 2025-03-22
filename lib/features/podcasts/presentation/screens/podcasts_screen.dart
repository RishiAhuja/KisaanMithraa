import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cropconnect/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:cropconnect/features/podcasts/domain/model/podcast_model.dart';
import 'package:cropconnect/features/podcasts/presentation/controllers/podcast_controller.dart';

class PodcastsScreen extends GetView<PodcastController> {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildTagsRow(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                if (controller.podcasts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.headphones_rounded,
                          size: 72,
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No podcasts available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color:
                                theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 8),
                    _buildFeaturedPodcast(context, controller.podcasts.first),
                    _buildSectionTitle(context, 'Popular Podcasts'),
                    ...controller.podcasts
                        .where((p) => p.plays > 0)
                        .take(5)
                        .map((podcast) =>
                            _buildPodcastListItem(context, podcast)),
                    _buildSectionTitle(context, 'New Releases'),
                    ...controller.podcasts.skip(1).map(
                        (podcast) => _buildPodcastListItem(context, podcast)),
                  ],
                );
              }),
            ),
            Obx(() {
              final currentPodcast = controller.currentPodcast.value;
              if (currentPodcast == null) return const SizedBox();

              return _buildMiniPlayer(context, currentPodcast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Farmer's Podcasts",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed('/podcasts/search');
            },
            icon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    final theme = Theme.of(context);
    final tags = [
      'All',
      'Farming',
      'Weather',
      'Crops',
      'Market',
      'Technology',
      'Government',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final tag = tags[index];

          return Obx(() {
            final isSelected = index == 0
                ? controller.currentTag.isEmpty
                : controller.currentTag.value == tag;

            return GestureDetector(
              onTap: () {
                controller.filterByTag(index == 0 ? '' : tag);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  tag,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color:
                        isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildFeaturedPodcast(BuildContext context, PodcastModel podcast) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: podcast.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.primary,
                  child: const Icon(
                    Icons.headphones_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/podcasts/player', arguments: podcast);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcast.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        podcast.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        podcast.durationFormatted,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Featured',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodcastListItem(BuildContext context, PodcastModel podcast) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.toNamed('/podcasts/player', arguments: podcast);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Podcast thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: podcast.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            child: Icon(
                              Icons.headphones_rounded,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_filled_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcast.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          podcast.author,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: theme.colorScheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              podcast.durationFormatted,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Spacer(),
                            Obx(() {
                              final isLiked =
                                  controller.likedPodcasts.contains(podcast.id);
                              return IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: isLiked
                                      ? Colors.red
                                      : theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                  size: 20,
                                ),
                                onPressed: () => controller.toggleLike(podcast),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${podcast.likes}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Tags row
                        if (podcast.tags.isNotEmpty)
                          SizedBox(
                            height: 22,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: podcast.tags.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    podcast.tags[index],
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              title.contains('Popular')
                  ? Icons.trending_up_rounded
                  : Icons.new_releases_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, PodcastModel podcast) {
    final theme = Theme.of(context);

    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.toNamed('/podcasts/player', arguments: podcast);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CachedNetworkImage(
                        imageUrl: podcast.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.headphones_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcast.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          podcast.author,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                    ),
                    onPressed: controller.playPreviousPodcast,
                  ),
                  Obx(() => IconButton(
                        icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: controller.togglePlayPause,
                      )),
                  IconButton(
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                    ),
                    onPressed: controller.playNextPodcast,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
