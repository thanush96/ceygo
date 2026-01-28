import 'dart:convert';

import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/home/presentation/providers/home_providers.dart';
import 'package:ceygo_app/features/home/presentation/widgets/car_card.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/core/network/services/vehicle_service.dart';
import 'package:ceygo_app/core/widgets/error_dialog.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? initialSearchQuery;
  final String? initialSelectedBrand;
  final String? initialSelectedLocation;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialSearchQuery,
    this.initialSelectedBrand,
    this.initialSelectedLocation,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  late String? _selectedBrand;
  List<Map<String, String>> _allBrands = [];
  bool _isLoadingBrands = false;

  @override
  void initState() {
    super.initState();
    final query = widget.initialSearchQuery ?? widget.initialQuery ?? '';
    _searchController = TextEditingController(text: query);
    _searchQuery = query;
    _selectedBrand = widget.initialSelectedBrand;
    _loadBrands();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoadingBrands = true;
    });
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/car_manufacturers.json',
      );
      final List<dynamic> data = jsonDecode(jsonStr) as List<dynamic>;
      _allBrands =
          data
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => {
                  'name': (e['name'] ?? '').toString(),
                  'logo': (e['thumb'] ?? '').toString(),
                },
              )
              .where((e) => e['name']!.isNotEmpty && e['logo']!.isNotEmpty)
              .toList();
    } catch (e) {
      // Ignore errors; keep list empty on failure
      _allBrands = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBrands = false;
        });
      }
    }
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
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          title: l10n.search,
          useCustomStyle: true,
          backgroundColor: Colors.transparent,
          leftIcon: Icons.arrow_back,
          onLeftPressed: () => context.pop(),
          onRightPressed: () {},
        ),

        // AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   leading: IconButton(
        //     onPressed: () => context.pop(),
        //     icon: Container(
        //       padding: const EdgeInsets.all(8),
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         shape: BoxShape.circle,
        //       ),
        //       child: const Icon(Icons.arrow_back, color: Colors.black),
        //     ),
        //   ),
        //   title: Text(
        //     l10n.search,
        //     style: theme.textTheme.titleLarge?.copyWith(
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   centerTitle: true,
        // ),
        body: SafeArea(
          child: Column(
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
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
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),

              // Brand Chips
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16.0,
                  right: 16,
                ),
                child:
                    _isLoadingBrands
                        ? const SizedBox(
                          height: 48,
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // "All" chip
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedBrand = null;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedBrand == null
                                            ? theme.primaryColor
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    border:
                                        _selectedBrand == null
                                            ? null
                                            : Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.apps,
                                        color:
                                            _selectedBrand == null
                                                ? Colors.white
                                                : Colors.black,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "All",
                                        style: TextStyle(
                                          color:
                                              _selectedBrand == null
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Brand chips from asset list
                              ..._allBrands.map((brand) {
                                final isSelected =
                                    _selectedBrand == brand['name'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedBrand = brand['name'];
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? theme.primaryColor
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border:
                                          isSelected
                                              ? null
                                              : Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: Image.network(
                                            brand['logo']!,
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (ctx, _, __) => Icon(
                                                  Icons.directions_car,
                                                  size: 18,
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : Colors.grey,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          brand['name']!,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
              ),

              // Search Results
              Expanded(
                child: carsAsyncValue.when(
                  data: (cars) {
                    // Filter cars based on search query and brand
                    var filteredCars = cars;

                    // Filter by brand
                    if (_selectedBrand != null) {
                      filteredCars =
                          filteredCars
                              .where((car) => car.brand == _selectedBrand)
                              .toList();
                    }

                    // Filter by search query
                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      filteredCars =
                          filteredCars
                              .where(
                                (car) =>
                                    car.name.toLowerCase().contains(query) ||
                                    car.brand.toLowerCase().contains(query) ||
                                    car.transmission.toLowerCase().contains(
                                      query,
                                    ) ||
                                    car.fuelType.toLowerCase().contains(query),
                              )
                              .toList();
                    }

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

                    if (_searchQuery.isEmpty && _selectedBrand == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
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
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
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
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
