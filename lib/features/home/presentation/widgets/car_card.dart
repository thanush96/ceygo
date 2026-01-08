import 'package:ceygo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const CarCard({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - Logo, Brand, Name, Rating
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Brand Logo
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Image.network(
                          car.brandLogo,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (ctx, _, __) => Icon(
                                Icons.directions_car,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Brand and Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   car.brand,
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     color: Colors.grey.shade600,
                            //   ),
                            // ),
                            Text(
                              car.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Specs Row
                            Row(
                              children: [
                                _CarSpecItem(
                                  icon: Icons.settings,
                                  text: car.transmission,
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.grey.shade600,
                                ),
                                // const SizedBox(width: 10),
                                // _CarSpecItem(
                                //   icon: Icons.local_gas_station,
                                //   text: car.fuelType,
                                // ),
                                const SizedBox(width: 5),
                                _CarSpecItem(
                                  icon: Icons.person,
                                  text: "${car.seats} Seats",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        // decoration: BoxDecoration(
                        //   color: Colors.grey.shade100,
                        //   borderRadius: BorderRadius.circular(12),
                        // ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 17,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${car.rating}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Image Section
            Container(
              height: 180,
              width: double.infinity,
              color: const Color.fromARGB(255, 255, 255, 255),
              child: Image.asset(
                car.imageUrl,
                fit: BoxFit.contain,
                errorBuilder:
                    (ctx, _, __) => const Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),

            // Price and Button Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\Rs.${car.pricePerDay.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: "/day",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'View Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      // child: const Icon(Icons.arrow_forward, color: Colors.white),
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
}

class _CarSpecItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CarSpecItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon(icon, size: 16, color: Colors.grey.shade700),
        // const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
