import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:index/models/anime.dart';
import 'package:index/models/anime_episode.dart';
import 'package:index/screens/base_screen.dart';
import 'package:index/screens/anime_player_screen.dart';
import 'package:index/services/anime_service.dart';

class AnimeDetailsScreen extends BaseScreen {
  final Anime anime;

  const AnimeDetailsScreen({
    super.key,
    required this.anime,
  });

  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends BaseScreenState<AnimeDetailsScreen> {
  final AnimeService _animeService = AnimeService();
  List<AnimeEpisode> _episodes = [];
  bool _isLoadingEpisodes = false;
  bool _showFullDescription = false;

  @override
  String get screenName => 'Anime Details';

  @override
  Future<void> initializeScreen() async {
    await _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _isLoadingEpisodes = true);
    
    try {
      final episodes = await _animeService.getAnimeEpisodes(
        widget.anime.id,
        widget.anime.displayTitle,
      );
      setState(() {
        _episodes = episodes;
        _isLoadingEpisodes = false;
      });
    } catch (e) {
      setState(() => _isLoadingEpisodes = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل الحلقات: $e')),
        );
      }
    }
  }

  void _playEpisode(AnimeEpisode episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimePlayerScreen(
          anime: widget.anime,
          episode: episode,
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Banner
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Banner Image
                  CachedNetworkImage(
                    imageUrl: widget.anime.bannerImage ?? widget.anime.coverImage ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, size: 50),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Basic Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.anime.coverImage ?? '',
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey[800],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 120,
                            height: 180,
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.anime.displayTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.anime.nativeTitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.anime.nativeTitle!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Rating
                            if (widget.anime.averageScore != null)
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(widget.anime.averageScore! / 10).toStringAsFixed(1)}/10',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            // Status and Episodes
                            _buildInfoChip('الحالة', widget.anime.statusText),
                            const SizedBox(height: 4),
                            if (widget.anime.episodes != null)
                              _buildInfoChip('الحلقات', '${widget.anime.episodes}'),
                            const SizedBox(height: 4),
                            _buildInfoChip('النوع', widget.anime.formatText),
                            if (widget.anime.year != null) ...[
                              const SizedBox(height: 4),
                              _buildInfoChip('السنة', '${widget.anime.year}'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Genres
                  if (widget.anime.genres.isNotEmpty) ...[
                    Text(
                      'الأنواع',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.anime.genres.map((genre) => Chip(
                        label: Text(
                          genre,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Description
                  if (widget.anime.description != null) ...[
                    Text(
                      'القصة',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _cleanDescription(widget.anime.description!),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                      maxLines: _showFullDescription ? null : 4,
                      overflow: _showFullDescription ? null : TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showFullDescription = !_showFullDescription),
                      child: Text(
                        _showFullDescription ? 'عرض أقل' : 'عرض المزيد',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Episodes Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الحلقات',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (_isLoadingEpisodes)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Episodes List
                  if (_episodes.isEmpty && !_isLoadingEpisodes)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'لا توجد حلقات متاحة حالياً',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _episodes.length,
                      itemBuilder: (context, index) {
                        final episode = _episodes[index];
                        return _buildEpisodeCard(episode);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeCard(AnimeEpisode episode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '${episode.episodeNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          episode.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: episode.description != null
            ? Text(
                episode.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54),
              )
            : null,
        trailing: const Icon(Icons.play_arrow),
        onTap: () => _playEpisode(episode),
      ),
    );
  }

  String _cleanDescription(String description) {
    // Remove HTML tags
    return description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#039;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}