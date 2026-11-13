import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const _shimmerBase = Color(0xFF262626);
const _shimmerHighlight = Color(0xFF3C3C3C);

Widget _shimmer(Widget child) {
  return Shimmer.fromColors(
    baseColor: _shimmerBase,
    highlightColor: _shimmerHighlight,
    child: child,
  );
}

Widget _block({double? width, double? height, double radius = 4}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class MediaListSkeleton extends StatelessWidget {
  final int itemCount;

  const MediaListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF202020),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF303030)),
            ),
            child: Row(
              children: [
                _block(width: 65, height: 90),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _block(height: 16),
                      const SizedBox(height: 10),
                      _block(width: 140, height: 13),
                      const SizedBox(height: 8),
                      _block(width: 90, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PosterRowSkeleton extends StatelessWidget {
  final bool featured;

  const PosterRowSkeleton({super.key, this.featured = false});

  @override
  Widget build(BuildContext context) {
    final cardWidth = featured ? 190.0 : 145.0;
    final posterHeight = featured ? 255.0 : 180.0;

    return SizedBox(
      height: featured ? 340 : 262,
      child: _shimmer(
        ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(height: posterHeight),
                  const SizedBox(height: 10),
                  _block(width: cardWidth - 30, height: 14),
                  const SizedBox(height: 6),
                  _block(width: 80, height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
