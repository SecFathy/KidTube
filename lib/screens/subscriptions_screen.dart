import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/video_card.dart';
import 'video_player_screen.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.allowedChannels.isEmpty && provider.regularVideos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.subscriptions_outlined,
                    size: 72, color: AppColors.ytGrey),
                SizedBox(height: 16),
                Text('No subscriptions yet',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text('Channels you subscribe to will show here',
                    style:
                        TextStyle(color: AppColors.ytGrey, fontSize: 14)),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Channel avatars row (YouTube-style horizontal scroll)
            if (provider.allowedChannels.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.ytDarkBg,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 94,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          itemCount: provider.allowedChannels.length + 1,
                          itemBuilder: (context, index) {
                            // "All" button first
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor:
                                          AppColors.ytDarkSurface,
                                      child: const Icon(
                                          Icons.grid_view_rounded,
                                          color: AppColors.white,
                                          size: 22),
                                    ),
                                    const SizedBox(height: 6),
                                    const SizedBox(
                                      width: 64,
                                      child: Text(
                                        'All',
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final channel =
                                provider.allowedChannels[index - 1];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor:
                                        AppColors.ytDarkSurface,
                                    backgroundImage:
                                        channel.avatarUrl.isNotEmpty
                                            ? CachedNetworkImageProvider(
                                                channel.avatarUrl)
                                            : null,
                                    child: channel.avatarUrl.isEmpty
                                        ? Text(
                                            channel.name.isNotEmpty
                                                ? channel.name[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight.w500),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 64,
                                    child: Text(
                                      channel.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: AppColors.ytGrey,
                                          fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 0.5),
                    ],
                  ),
                ),
              ),

            // "Today" label
            if (provider.regularVideos.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Videos list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = provider.regularVideos[index];
                  return VideoCard(
                    video: video,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoPlayerScreen(video: video),
                        ),
                      );
                    },
                  );
                },
                childCount: provider.regularVideos.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
