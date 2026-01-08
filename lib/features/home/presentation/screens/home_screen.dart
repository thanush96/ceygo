import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/home/presentation/providers/home_providers.dart';
import 'package:ceygo_app/features/home/presentation/widgets/car_card.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/features/home/data/mock_car_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsyncValue = ref.watch(carListProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                "Colombo, Sri Lanka",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => context.push('/profile'), // Profile
              icon: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Find Your\nPerfect Ride",
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    GestureDetector(
                      onTap: () {
                        // context.push('/search'); // TODO: Implement Search
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 12),
                            Text(
                              l10n.search,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Brand Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // "All" chip
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.apps,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "All",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Brand chips from mock data
                          ...MockCarRepository.getBrands().map((brand) {
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      brand['logo']!,
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (ctx, _, __) => const Icon(
                                            Icons.directions_car,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    brand['name']!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 32),

                    // Car List Header
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     const Text(
                    //       "Popular Cars",
                    //       style: TextStyle(
                    //         fontSize: 20,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //     TextButton(
                    //       onPressed: () {},
                    //       child: const Text("See All"),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Car List Grid
            carsAsyncValue.when(
              data:
                  (cars) => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final car = cars[index];
                        return CarCard(
                          car: car,
                          onTap: () {
                            context.push('/car-details/${car.id}');
                          },
                        );
                      }, childCount: cars.length),
                    ),
                  ),
              error:
                  (err, stack) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $err')),
                  ),
              loading:
                  () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
