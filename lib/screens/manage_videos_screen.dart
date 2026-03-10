import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class ManageVideosScreen extends StatelessWidget {
  const ManageVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ytDarkBg,
      appBar: AppBar(
        backgroundColor: AppColors.ytDarkBg,
        title: const Text('Manage Videos',
            style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.allVideos.isEmpty) {
            return const Center(
              child: Text(
                'No videos added yet',
                style: TextStyle(color: AppColors.ytGrey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.allVideos.length,
            itemBuilder: (context, index) {
              final video = provider.allVideos[index];
              return Dismissible(
                key: Key(video.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.ytRed,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.removeVideo(video.id),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 120,
                      height: 68,
                      child: CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            color: AppColors.ytDarkSurface),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.ytDarkSurface,
                          child: const Icon(Icons.error,
                              color: AppColors.ytGrey),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.white, fontSize: 13),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        video.channelName,
                        style: const TextStyle(
                            color: AppColors.ytGrey, fontSize: 11),
                      ),
                      if (video.isShort) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.ytRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SHORT',
                            style: TextStyle(
                                color: Colors.white, fontSize: 9,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.ytRed, size: 22),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.ytDarkSurface,
                          title: const Text('Remove Video',
                              style: TextStyle(color: AppColors.white)),
                          content: Text(
                            'Remove "${video.title}" from the approved list?',
                            style: const TextStyle(color: AppColors.ytGrey),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel',
                                  style:
                                      TextStyle(color: AppColors.ytGrey)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                provider.removeVideo(video.id);
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.ytRed),
                              child: const Text('Remove',
                                  style:
                                      TextStyle(color: AppColors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
