import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/features/home/presentation/providers/home_providers.dart';
import 'package:ceygo_app/core/widgets/photo_gallery.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';

// Constants
class _AppColors {
  static const primaryBlue = Color(0xFF2563EB);
  static const gradientStart = Color.fromARGB(255, 219, 240, 255);
  static final gradientEnd = Color.fromARGB(255, 237, 243, 246);
}

class _Dimensions {
  static const double cardRadius = 20.0;
  static const double bottomButtonRadius = 40.0;
}

class CarDetailsScreen extends ConsumerWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carListProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_AppColors.gradientStart, _AppColors.gradientEnd],
          ),
        ),
        child: carsAsync.when(
          data: (cars) {
            final car = cars.firstWhere(
              (c) => c.id == carId,
              orElse: () => cars.first,
            );
            return _CarDetailsContent(car: car);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(child: Text("Error loading details")),
        ),
      ),
    );
  }
}

class _CarDetailsContent extends ConsumerWidget {
  final dynamic car;

  const _CarDetailsContent({required this.car});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider.notifier);
    final favoritesList = ref.watch(favoritesProvider);
    final isFavorite = favoritesList.any((c) => c.id == car.id);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              _HeroSection(car: car),
              _RenterCard(car: car),
              const SizedBox(height: 100),
            ],
          ),
        ),
        CustomAppBar(
          title: 'Car Detail',
          useCustomStyle: true,
          backgroundColor: _AppColors.gradientStart,
          leftIcon: Icons.arrow_back,
          onLeftPressed: () => context.pop(),
          rightIcon: isFavorite ? Icons.favorite : Icons.favorite_border,
          onRightPressed: () => favorites.toggleFavorite(car),
        ),
        _BottomBookButton(car: car),
      ],
    );
  }
}

// Hero Section
class _HeroSection extends StatelessWidget {
  final dynamic car;

  const _HeroSection({required this.car});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CarImageWithSpecs(car: car),
          const SizedBox(height: 20),
          PhotoGallery(car: car),
          const SizedBox(height: 20),
          _DescriptionCard(car: car),
        ],
      ),
    );
  }
}

class _CarImageWithSpecs extends StatelessWidget {
  final dynamic car;

  const _CarImageWithSpecs({required this.car});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: 20,
            child: Image.asset(
              car.imageUrl,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const Icon(
                    Icons.directions_car,
                    size: 200,
                    color: Colors.grey,
                  ),
            ),
          ),
          Positioned(
            left: 20,
            top: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.name}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const _SpecItem(label: 'Power', value: '220kw'),
                const SizedBox(height: 16),
                const _SpecItem(label: '0 - 100 km/h', value: '5.1sec'),
                const SizedBox(height: 16),
                const _SpecItem(label: 'Top speed', value: '275 kmh'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final dynamic car;

  const _DescriptionCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text:
                      'Experience pure performance with the ${car.brand} ${car.name} — a masterpiece built for thrill-seekers. Its 4.0-liter engine. ',
                ),
                // TextSpan(
                //   text: 'See More...',
                //   style: TextStyle(
                //     color: Colors.blue.shade600,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RenterCard extends StatelessWidget {
  final dynamic car;

  const _RenterCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Renter',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alexander',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '4.9 (28 reviews)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _ActionButton(
                icon: Icons.message,
                onPressed: () => context.push('/chat'),
              ),
              const SizedBox(width: 8),
              _ActionButton(icon: Icons.phone, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Pickup Location: 2715 Ash Dr. San Jose',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: _AppColors.primaryBlue,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _BottomBookButton extends StatelessWidget {
  final dynamic car;

  const _BottomBookButton({required this.car});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 15,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(_Dimensions.bottomButtonRadius),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Rs ${car.pricePerDay.toStringAsFixed(0)}/day',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () => context.push('/checkout', extra: car),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Book Rent',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shared Widgets
class _SpecItem extends StatelessWidget {
  final String label;
  final String value;

  const _SpecItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// Shared decoration
BoxDecoration get _cardDecoration => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(_Dimensions.cardRadius),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ],
);
