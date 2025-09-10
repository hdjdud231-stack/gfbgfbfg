import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:index/models/anime.dart';
import 'package:index/screens/base_screen.dart';
import 'package:index/screens/anime_details_screen.dart';
import 'package:index/services/anime_service.dart';

class AnimeXScreen extends BaseScreen {
  const AnimeXScreen({super.key});

  @override
  State<AnimeXScreen> createState() => _AnimeXScreenState();
}

class _AnimeXScreenState extends BaseScreenState<AnimeXScreen> {
  final AnimeService _animeService = AnimeService();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Anime> _trendingAnime = [];
  List<Anime> _popularAnime = [];
  List<Anime> _topRatedAnime = [];
  List<Anime> _searchResults = [];
  
  bool _isLoadingTrending = true;
  bool _isLoadingPopular = true;
  bool _isLoadingTopRated = true;
  bool _isSearching = false;
  bool _showSearchResults = false;
  
  int _currentPage = 0;

  @override
  String get screenName => 'AnimeX';

  @override
  Future<void> initializeScreen() async {
    await _loadTrendingAnime();
    await _loadPopularAnime();
    await _loadTopRatedAnime();
  }

  Future<void> _loadTrendingAnime() async {
    setState(() => _isLoadingTrending = true);
    
    try {
      final anime = await _animeService.getTrendingAnime();
      setState(() {
        _trendingAnime = anime;
        _isLoadingTrending = false;
      });
    } catch (e) {
      setState(() => _isLoadingTrending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل الأنمي الرائج: $e')),
        );
      }
    }
  }

  Future<void> _loadPopularAnime() async {
    setState(() => _isLoadingPopular = true);
    
    try {
      final anime = await _animeService.getPopularAnime();
      setState(() {
        _popularAnime = anime;
        _isLoadingPopular = false;
      });
    } catch (e) {
      setState(() => _isLoadingPopular = false);
    }
  }

  Future<void> _loadTopRatedAnime() async {
    setState(() => _isLoadingTopRated = true);
    
    try {
      final anime = await _animeService.getTopRatedAnime();
      setState(() {
        _topRatedAnime = anime;
        _isLoadingTopRated = false;
      });
    } catch (e) {
      setState(() => _isLoadingTopRated = false);
    }
  }

  Future<void> _searchAnime(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final results = await _animeService.searchAnime(query);
      setState(() {
        _searchResults = results;
        _showSearchResults = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في البحث: $e')),
        );
      }
    }
  }

  void _navigateToAnimeDetails(Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailsScreen(anime: anime),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimeX'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchAnime,
              decoration: InputDecoration(
                hintText: 'البحث عن الأنمي...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchAnime('');
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
      ),
      body: _showSearchResults
          ? _buildSearchResults()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Anime Carousel
                  if (_trendingAnime.isNotEmpty) _buildFeaturedCarousel(),
                  
                  // Trending Section
                  _buildSection(
                    title: 'الأنمي الرائج',
                    animeList: _trendingAnime,
                    isLoading: _isLoadingTrending,
                  ),
                  
                  // Popular Section
                  _buildSection(
                    title: 'الأكثر شعبية',
                    animeList: _popularAnime,
                    isLoading: _isLoadingPopular,
                  ),
                  
                  // Top Rated Section
                  _buildSection(
                    title: 'الأعلى تقييماً',
                    animeList: _topRatedAnime,
                    isLoading: _isLoadingTopRated,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Container(
      height: 300,
      margin: const EdgeInsets.only(bottom: 20),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _trendingAnime.take(5).length,
        itemBuilder: (context, index) {
          final anime = _trendingAnime[index];
          return GestureDetector(
            onTap: () => _navigateToAnimeDetails(anime),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: anime.bannerImage ?? anime.coverImage ?? '',
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
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anime.displayTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (anime.averageScore != null) ...[
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${(anime.averageScore! / 10).toStringAsFixed(1)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (anime.episodes != null) ...[
                              const Icon(Icons.play_circle_outline, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${anime.episodes} حلقة',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Anime> animeList,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 280,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: animeList.length,
                  itemBuilder: (context, index) {
                    final anime = animeList[index];
                    return _buildAnimeCard(anime);
                  },
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAnimeCard(Anime anime) {
    return GestureDetector(
      onTap: () => _navigateToAnimeDetails(anime),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: anime.coverImage ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              anime.displayTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Rating and Episodes
            Row(
              children: [
                if (anime.averageScore != null) ...[
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '${(anime.averageScore! / 10).toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty && !_isSearching
        ? const Center(
            child: Text(
              'لا توجد نتائج',
              style: TextStyle(fontSize: 18, color: Colors.white54),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final anime = _searchResults[index];
              return _buildSearchResultCard(anime);
            },
          );
  }

  Widget _buildSearchResultCard(Anime anime) {
    return GestureDetector(
      onTap: () => _navigateToAnimeDetails(anime),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: anime.coverImage ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie, size: 40),
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (anime.averageScore != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${(anime.averageScore! / 10).toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ],
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

  @override
  void handleDispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.handleDispose();
  }
}