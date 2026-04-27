import 'package:flutter/material.dart';

class CastCrewSection extends StatelessWidget {
  final List<dynamic> castList;

  const CastCrewSection({super.key, required this.castList});

  @override
  Widget build(BuildContext context) {
    if (castList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 14, top: 14, bottom: 8),
          child: Text(
            "Cast & Crew",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 14),
            itemCount: castList.length,
            itemBuilder: (context, index) {
              final cast = castList[index];
              final name = cast['name']?.toString() ?? '';
              final image = cast['image']?.toString() ?? '';

              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: image.startsWith('http')
                          ? NetworkImage(image)
                          : null,
                      backgroundColor: Colors.grey[800],
                      child: !image.startsWith('http')
                          ? const Icon(Icons.person, color: Colors.white54)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}