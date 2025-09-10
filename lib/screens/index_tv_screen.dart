import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:index/models/tv_channel.dart';
import 'package:index/screens/base_screen.dart';
import 'package:index/screens/tv_player_screen.dart';
import 'package:index/services/iptv_service.dart';
import 'package:index/components/spinner.dart';

class IndexTvScreen extends BaseScreen {
  const IndexTvScreen({super.key});

  @override
  State<IndexTvScreen> createState() => _IndexTvScreenState();
}

class _IndexTvScreenState extends BaseScreenState<IndexTvScreen> {
  final IptvService _iptvService = IptvService();
  List<TvChannel> _channels = [];
  List<TvChannel> _filteredChannels = [];
  Map<String, String> _countryNames = {};
  String _selectedCountry = 'all';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  String get screenName => 'Index TV';

  @override
  Future<void> initializeScreen() async {
    await _loadChannels();
    await _loadCountryNames();
  }

  Future<void> _loadChannels() async {
    setState(() => _isLoading = true);
    
    try {
      final channels = await _iptvService.getAllChannels();
      setState(() {
        _channels = channels;
        _filteredChannels = channels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل القنوات: $e')),
        );
      }
    }
  }

  Future<void> _loadCountryNames() async {
    final countryNames = await _iptvService.getCountryNames();
    setState(() => _countryNames = countryNames);
  }

  void _filterChannels() {
    List<TvChannel> filtered = _channels;

    // Filter by country
    if (_selectedCountry != 'all') {
      filtered = filtered.where((channel) => 
          channel.country?.toLowerCase() == _selectedCountry.toLowerCase()).toList();
    }

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((channel) => 
          channel.category?.toLowerCase().contains(_selectedCategory.toLowerCase()) == true).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((channel) =>
          channel.name.toLowerCase().contains(query) ||
          (channel.category?.toLowerCase().contains(query) == true) ||
          (channel.country?.toLowerCase().contains(query) == true)
      ).toList();
    }

    setState(() => _filteredChannels = filtered);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterChannels();
  }

  void _onCountryChanged(String? country) {
    setState(() => _selectedCountry = country ?? 'all');
    _filterChannels();
  }

  void _onCategoryChanged(String? category) {
    setState(() => _selectedCategory = category ?? 'all');
    _filterChannels();
  }

  void _playChannel(TvChannel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TvPlayerScreen(channel: channel),
      ),
    );
  }

  List<String> _getUniqueCategories() {
    final categories = _channels
        .where((channel) => channel.category != null && channel.category!.isNotEmpty)
        .map((channel) => channel.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Index TV'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _iptvService.refreshChannels();
              await _loadChannels();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'البحث عن القنوات...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                ),
                const SizedBox(height: 12),
                // Filters Row
                Row(
                  children: [
                    // Country Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: InputDecoration(
                          labelText: 'الدولة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('جميع الدول')),
                          ..._countryNames.entries.map((entry) =>
                              DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              )),
                        ],
                        onChanged: _onCountryChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'الفئة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('جميع الفئات')),
                          ..._getUniqueCategories().map((category) =>
                              DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              )),
                        ],
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Channels Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredChannels.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد قنوات متاحة',
                          style: TextStyle(fontSize: 18, color: Colors.white54),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredChannels.length,
                        itemBuilder: (context, index) {
                          final channel = _filteredChannels[index];
                          return _buildChannelCard(channel);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelCard(TvChannel channel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _playChannel(channel),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Channel Logo
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  child: channel.logo != null && channel.logo!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: channel.logo!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.tv,
                              size: 40,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.tv,
                          size: 40,
                          color: Colors.white54,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              // Channel Name
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (channel.quality != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          channel.quality!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}