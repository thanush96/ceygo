import 'package:flutter/material.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
  });

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
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                   Container(
                     height: 180,
                     width: double.infinity,
                     color: Colors.grey.shade100,
                     child: Image.asset(
                       car.imageUrl, 
                       fit: BoxFit.cover,
                       errorBuilder: (ctx, _, __) => const Center(
                         child: Icon(Icons.directions_car, size: 64, color: Colors.grey),
                       ),
                     ),
                   ),
                   Positioned(
                     top: 12,
                     right: 12,
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           const Icon(Icons.star, color: Colors.amber, size: 16),
                           const SizedBox(width: 4),
                           Text(
                             "${car.rating}",
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                           ),
                         ],
                       ),
                     ),
                   )
                ],
              ),
            ),
            
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${car.brand} ${car.name}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                       _CarSpecItem(icon: Icons.settings, text: car.transmission),
                       const SizedBox(width: 16),
                       _CarSpecItem(icon: Icons.local_gas_station, text: car.fuelType),
                       const SizedBox(width: 16),
                       _CarSpecItem(icon: Icons.person, text: "${car.seats} Seats"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Price and Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\$${car.pricePerDay.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ],
                  ),
                ],
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
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
