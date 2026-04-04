import 'package:ceygo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/custom_app_bar.dart';
import 'package:ceygo_app/features/owner/presentation/providers/owner_providers.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';

class MyVehiclesScreen extends ConsumerWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(title: 'My Vehicles'),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No vehicles yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first vehicle to start earning',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/owner/add-vehicle'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(myVehiclesProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length + 1, // +1 for bottom padding
              itemBuilder: (context, index) {
                if (index == vehicles.length)
                  return const SizedBox(height: 100);
                return _VehicleCard(vehicle: vehicles[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load vehicles',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(myVehiclesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () => context.push('/owner/add-vehicle'),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  final Car vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationStatus = vehicle.verificationStatus.toLowerCase();
    final isVerificationPending =
        verificationStatus == 'pending' || vehicle.isVerified == false;

    return GestureDetector(
      onTap: isVerificationPending
          ? null
          : () => context.push('/owner/edit-vehicle', extra: vehicle),
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
            // ── Top Section: brand logo · name · specs · action corner ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Row(
                    children: [
                      // Brand logo circle
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Image.network(
                          vehicle.brandLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.directions_car,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name + specs
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.brand} ${vehicle.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                _SpecItem(
                                  icon: Icons.settings,
                                  text: vehicle.transmission,
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 5),
                                _SpecItem(
                                  icon: Icons.person,
                                  text: '${vehicle.seats} Seats',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Right corner: PENDING badge OR edit/delete menu
                      if (isVerificationPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF59E0B).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'PENDING',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Vehicle'),
                                  content: const Text(
                                      'Are you sure you want to delete this vehicle?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Delete',
                                          style:
                                              TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await ref
                                      .read(myVehiclesProvider.notifier)
                                      .deleteVehicle(vehicle.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                            content:
                                                Text('Vehicle deleted')));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                'Failed to delete: $e')));
                                  }
                                }
                              }
                            } else if (value == 'edit') {
                              context.push('/owner/edit-vehicle',
                                  extra: vehicle);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ]),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ]),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Car image ──
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                vehicle.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.directions_car,
                      size: 64, color: Colors.grey),
                ),
              ),
            ),

            // ── Price pill + action button ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  color: isVerificationPending
                      ? const Color(0xFFF59E0B).withOpacity(0.08)
                      : AppTheme.primaryColor.withOpacity(0.1),
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
                              text:
                                  'Rs ${vehicle.pricePerDay.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '/day',
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
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isVerificationPending
                            ? const Color(0xFFF59E0B)
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        isVerificationPending
                            ? 'Verification Pending'
                            : 'Edit Vehicle',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Pending notice ──
            if (isVerificationPending)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                child: Text(
                  'This vehicle is under review and cannot be edited until verified.',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SpecItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
