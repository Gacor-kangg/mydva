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

/// Skeleton banner (hero) di bagian atas homepage.
class HeroSkeleton extends StatelessWidget {
  /// Tinggi area header + status bar (supaya isi tidak tertutup header).
  final double topInset;
  final bool wide;

  const HeroSkeleton({super.key, required this.topInset, required this.wide});

  Widget _textBlocks() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _block(width: 80, height: 14),
        const SizedBox(height: 14),
        _block(width: wide ? 360 : 170, height: wide ? 34 : 24),
        const SizedBox(height: 12),
        _block(width: 150, height: 14),
        const SizedBox(height: 18),
        _block(height: 12),
        const SizedBox(height: 8),
        _block(height: 12),
        const SizedBox(height: 8),
        _block(width: wide ? 280 : 120, height: 12),
        const SizedBox(height: 20),
        _block(width: 120, height: 38, radius: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentHeight = wide ? 360.0 : 320.0;
    final poster = _block(
      width: wide ? 190 : 100,
      height: wide ? 285 : 150,
      radius: 8,
    );

    return SizedBox(
      height: topInset + contentHeight,
      width: double.infinity,
      child: _shimmer(
        Padding(
          padding: EdgeInsets.fromLTRB(
            wide ? 64 : 18,
            topInset + (wide ? 24 : 14),
            wide ? 64 : 18,
            wide ? 36 : 34,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: _textBlocks()),
                        const SizedBox(width: 40),
                        poster,
                      ],
                    )
                  : Row(
                      children: [
                        poster,
                        const SizedBox(width: 16),
                        Expanded(child: _textBlocks()),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatarSkeleton extends StatelessWidget {
  final double radius;

  const ProfileAvatarSkeleton({super.key, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SearchResultSkeleton extends StatelessWidget {
  final int count;

  const SearchResultSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return _shimmer(
      SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            for (int i = 0; i < count; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    _block(width: 56, height: 84, radius: 6),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _block(width: 180, height: 16),
                          const SizedBox(height: 8),
                          _block(width: 70, height: 18, radius: 9),
                          const SizedBox(height: 10),
                          _block(height: 11),
                          const SizedBox(height: 6),
                          _block(width: 140, height: 11),
                        ],
                      ),
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