import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/home/presentation/providers/home_providers.dart';
import 'package:ceygo_app/features/home/presentation/widgets/car_card.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchQuery = widget.initialQuery ?? '';
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final carsAsyncValue = ref.watch(carListProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          title: Text(
            l10n.search,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        autofocus: true,
                        enabled: true,
                        decoration: InputDecoration(
                          hintText: l10n.search,
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: _performSearch,
                        onChanged: (value) {
                          // Real-time search as user types
                          _performSearch(value);
                        },
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          _performSearch(_searchController.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),

            // Search Results
            Expanded(
              child: carsAsyncValue.when(
                data: (cars) {
                  // Filter cars based on search query
                  final filteredCars =
                      _searchQuery.isEmpty
                          ? cars
                          : cars.where((car) {
                            final query = _searchQuery.toLowerCase();
                            return car.name.toLowerCase().contains(query) ||
                                car.brand.toLowerCase().contains(query) ||
                                car.transmission.toLowerCase().contains(
                                  query,
                                ) ||
                                car.fuelType.toLowerCase().contains(query);
                          }).toList();

                  if (_searchQuery.isNotEmpty && filteredCars.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No cars found for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_searchQuery.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Search for cars',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter car name, brand, or type',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: filteredCars.length,
                    itemBuilder: (context, index) {
                      final car = filteredCars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          context.push('/car-details/${car.id}');
                        },
                      );
                    },
                  );
                },
                error: (err, stack) => Center(child: Text('Error: $err')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
