import 'package:flutter/material.dart';

class PhotoGallery extends StatelessWidget {
  final dynamic car;
  final double? height;
  final double? photoSize;

  const PhotoGallery({
    super.key,
    required this.car,
    this.height,
    this.photoSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePhotoSize = photoSize ?? (screenWidth > 600 ? 100.0 : 80.0);

    return SizedBox(
      height: height ?? responsivePhotoSize,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (_, index) {
          if (index == 3) return MorePhotosCard(photoSize: responsivePhotoSize);
          return Container(
            width: responsivePhotoSize,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: AssetImage(car.imageUrl),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
          );
        },
      ),
    );
  }
}

class MorePhotosCard extends StatelessWidget {
  final double photoSize;

  const MorePhotosCard({super.key, required this.photoSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: photoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.7),
      ),
      child: const Center(
        child: Text(
          '+5',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
