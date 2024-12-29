//community_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.separated(
            itemCount: _feedItems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final item = _feedItems[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarImage(item.user.imageUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: item.user.fullName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                      TextSpan(
                                          text: " @${item.user.userName}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                    ]),
                                  )),
                              Text('· 4h',
                                  style: Theme.of(context).textTheme.titleSmall),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.more_horiz),
                              )
                            ],
                          ),
                          if (item.content != null) Text(item.content!),
                          if (item.imageUrl != null)
                            Container(
                              height: 200,
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(item.imageUrl!),
                                  )),
                            ),
                          _ActionsRow(item: item)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
class _AvatarImage extends StatelessWidget {
  final String url;
  const _AvatarImage(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url))),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final FeedItem item;
  const _ActionsRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.grey, size: 18),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.grey),
              ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
            label: Text(
                item.commentsCount == 0 ? '' : item.commentsCount.toString()),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.repeat_rounded),
            label: Text(
                item.retweetsCount == 0 ? '' : item.retweetsCount.toString()),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: Text(item.likesCount == 0 ? '' : item.likesCount.toString()),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

class FeedItem {
  final String? content;
  final String? imageUrl;
  final User user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;

  FeedItem(
      {this.content,
        this.imageUrl,
        required this.user,
        this.commentsCount = 0,
        this.likesCount = 0,
        this.retweetsCount = 0});
}

class User {
  final String fullName;
  final String imageUrl;
  final String userName;

  User(
      this.fullName,
      this.userName,
      this.imageUrl,
      );
}

final List<User> _users = [
  User(
    "Jin Yan",
    "jytan",
    "assets/leaderboard/avatar1.png",
  ),
  User(
    "Hakim",
    "kimm",
    "assets/leaderboard/avatar10.png",
  ),
];

final List<FeedItem> _feedItems = [
  FeedItem(
    content:
    "I choose to bike to work daily rather than driving. It’s amazing how small changes can have a big impact!",
    user: _users[0],
    imageUrl: "assets/bike.jpg",  // Change to asset path
    likesCount: 100,
    commentsCount: 10,
    retweetsCount: 1,
  ),
  FeedItem(
      user: _users[1],
      content: "I've started using reusable bags for grocery shopping. It feels great to be part of the solution!",
      imageUrl: "assets/bag.jpg",  // Change to asset path
      likesCount: 10,
      commentsCount: 2),
  FeedItem(
      user: _users[0],
      content:
      "Switched to solar-powered lights for my garden. Not only is it eco-friendly, but it also saves energy!",
      likesCount: 50,
      commentsCount: 22,
      retweetsCount: 30),
  FeedItem(
      user: _users[1],
      content:
      "Started composting at home! It's amazing how much waste we can divert from landfills and turn into valuable soil.",
      imageUrl: "assets/compositing.jpg",  // Change to asset path
      likesCount: 500,
      commentsCount: 202,
      retweetsCount: 120),
  FeedItem(
    user: _users[0],
    content: "Good morning! Today, I planted a tree in my backyard to contribute to a greener planet!",
    imageUrl: "assets/tree.jpg",
  ),
  FeedItem(
    user: _users[1],
    content: "I’ve been cutting down on single-use plastics by switching to glass containers. It’s a simple but effective change!",
    imageUrl: "assets/glass.jpg",
  ),
  FeedItem(
      user: _users[0],
      content: "Started a neighborhood clean-up initiative last weekend. The environment is everyone’s responsibility!",
      imageUrl: "assets/cleanup.jpg",
      ),
];