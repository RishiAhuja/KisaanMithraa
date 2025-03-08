import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/utils/app_logger.dart';
import '../../domain/models/cooperative_model.dart';
import '../controllers/my_cooperatives_controller.dart';

class SearchCooperativesScreen extends StatefulWidget {
  const SearchCooperativesScreen({Key? key}) : super(key: key);

  @override
  _SearchCooperativesScreenState createState() =>
      _SearchCooperativesScreenState();
}

class _SearchCooperativesScreenState extends State<SearchCooperativesScreen> {
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  List<CooperativeModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCooperatives(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final nameStartsWithQuery = await _firestore
          .collection('cooperatives')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      final results = <CooperativeModel>[];

      for (var doc in nameStartsWithQuery.docs) {
        results.add(CooperativeModel.fromMap(doc.data()));
      }

      final uniqueResults = <CooperativeModel>[];
      final addedIds = <String>{};

      for (var coop in results) {
        if (!addedIds.contains(coop.id)) {
          uniqueResults.add(coop);
          addedIds.add(coop.id);
        }
      }

      setState(() {
        _searchResults = uniqueResults;
        _isSearching = false;
      });

      AppLogger.debug(
          'Found ${_searchResults.length} cooperatives for query "$query"');
    } catch (e) {
      AppLogger.error('Error searching cooperatives: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search cooperatives...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: TextStyle(color: theme.colorScheme.onSurface),
          autofocus: true,
          onChanged: (value) {
            // Debounce search for better performance
            Future.delayed(Duration(milliseconds: 300), () {
              if (_searchController.text == value) {
                _searchCooperatives(value);
              }
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults = [];
                _hasSearched = false;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            LinearProgressIndicator(
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: theme.colorScheme.primary,
            ),
          Expanded(
            child: _hasSearched
                ? _searchResults.isEmpty && !_isSearching
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No cooperatives found',
                              style: theme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Try a different search term',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final coop = _searchResults[index];
                          return _CooperativeSearchResult(
                            cooperative: coop,
                            onTap: () => Get.toNamed(
                              '/cooperative-details',
                              arguments: CooperativeWithRole(
                                cooperative: coop,
                                role: 'viewer',
                              ),
                            ),
                          );
                        },
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for cooperatives',
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Find cooperatives by name or location',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CooperativeSearchResult extends StatelessWidget {
  final CooperativeModel cooperative;
  final VoidCallback onTap;

  const _CooperativeSearchResult({
    required this.cooperative,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    cooperative.name.isNotEmpty
                        ? cooperative.name[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cooperative.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cooperative.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${cooperative.members.length} members',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                cooperative.status.toLowerCase() == 'verified'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cooperative.status.capitalize!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  cooperative.status.toLowerCase() == 'verified'
                                      ? Colors.green
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
