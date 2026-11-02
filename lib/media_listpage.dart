import 'package:flutter/material.dart';
import 'media_data.dart';
import 'poster_image.dart';
import 'models/media_model.dart';
import 'media_detail_page.dart';
import 'ui_effects.dart';

class MediaListPage extends StatefulWidget {
  final String initialType;

  const MediaListPage({
    super.key,
    this.initialType = 'Film',
  });

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {

  String selectedType = 'Film';
  String selectedSort = 'Popular';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType;
  }

  List<MediaModel> get currentData {
    if (selectedType == 'Film') {
      return movieData;
    }

    if (selectedType == 'Series') {
      return seriesData;
    }

    return animeData;
  }

  List<MediaModel> get filteredData {

    List<MediaModel> result = List.from(currentData);

    // SEARCH
    if (searchQuery.isNotEmpty) {
      result = result.where((media) {
        return media.title
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }

    // SORT
    if (selectedSort == 'A-Z') {
      result.sort(
        (a, b) => a.title.compareTo(b.title),
      );
    }

    if (selectedSort == 'Newest') {
      result.sort(
        (a, b) =>
            (b.releaseYear ?? 0).compareTo(
              a.releaseYear ?? 0,
            ),
      );
    }

    if (selectedSort == 'Oldest') {
      result.sort(
        (a, b) =>
            (a.releaseYear ?? 0).compareTo(
              b.releaseYear ?? 0,
            ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),

      appBar: AppBar(
        backgroundColor: const Color(0xFF202020),
        foregroundColor: Colors.white,

        title: const Text(
          'Media List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [

            // ==============================
            // SEARCH
            // ==============================

            TextField(
              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                hintText: 'Search media...',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),

                filled: true,
                fillColor: const Color(0xFF202020),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 14),

            // ==============================
            // DROPDOWNS
            // ==============================

            Row(
              children: [

                // MEDIA TYPE
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedType,

                    dropdownColor:
                        const Color(0xFF202020),

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Media Type',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Color(0xFF202020),
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'Film',
                        child: Text('Film'),
                      ),
                      DropdownMenuItem(
                        value: 'Series',
                        child: Text('Series'),
                      ),
                      DropdownMenuItem(
                        value: 'Anime',
                        child: Text('Anime'),
                      ),
                    ],

                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // SORT
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSort,

                    dropdownColor:
                        const Color(0xFF202020),

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Color(0xFF202020),
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'Popular',
                        child: Text('Popular'),
                      ),
                      DropdownMenuItem(
                        value: 'Newest',
                        child: Text('Newest'),
                      ),
                      DropdownMenuItem(
                        value: 'Oldest',
                        child: Text('Oldest'),
                      ),
                      DropdownMenuItem(
                        value: 'A-Z',
                        child: Text('A-Z'),
                      ),
                    ],

                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedSort = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==============================
            // LIST
            // ==============================

            Expanded(
              child: filteredData.isEmpty
                  ? const Center(
                      child: Text(
                        'Media tidak ditemukan.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredData.length,

                      itemBuilder: (context, index) {

                        final media =
                            filteredData[index];

                        return _mediaListItem(media);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEDIA LIST ITEM
  // ============================================================

  Widget _mediaListItem(MediaModel media) {
    return HoverLift(
      hoverScale: 1.01,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetailPage(media: media),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF303030),
        ),
      ),

      child: Row(
        children: [

          // POSTER
          ClipRRect(
            borderRadius: BorderRadius.circular(4),

            child: PosterImage(
              media: media,
              width: 65,
              height: 90,
              placeholderColor: Colors.grey.shade800,
              textColor: Colors.grey,
              textSize: 24,
            ),
          ),

          const SizedBox(width: 14),

          // INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  media.title,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '${media.genre ?? selectedType} • ${media.releaseYear ?? '-'}',

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
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