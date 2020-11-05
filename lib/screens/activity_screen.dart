import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram/utilities/themes.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:instagram/services/services.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/screens.dart';
import 'package:instagram/utilities/constants.dart';

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  ActivityScreen({this.currentUserId});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> _activities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    setState(() => _isLoading = true);
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    }
  }

  _buildActivity(Activity activity) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(activity.fromUserId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User user = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.grey,
            backgroundImage: user.profileImageUrl.isEmpty
                ? AssetImage(placeHolderImageRef)
                : CachedNetworkImageProvider(user.profileImageUrl),
          ),
          title: activity.isFollowEvent
              ? Row(
                  children: <Widget>[
                    Text('${user.name} ', style: kFontWeightBoldTextStyle),
                    Text('started following you'),
                  ],
                )
              : activity.comment != null
                  ? Row(
                      children: <Widget>[
                        Text('${user.name} ', style: kFontWeightBoldTextStyle),
                        Expanded(
                            child: Text(
                          'commented: "${activity.comment}',
                          overflow: TextOverflow.ellipsis,
                        )),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Text('${user.name} ', style: kFontWeightBoldTextStyle),
                        Text('liked your post'),
                      ],
                    ),
          subtitle: Text(
            timeago.format(activity.timestamp.toDate()),
          ),
          trailing: activity.isFollowEvent
              ? SizedBox.shrink()
              : CachedNetworkImage(
                  imageUrl: activity.postImageUrl,
                  height: 40.0,
                  width: 40.0,
                  fit: BoxFit.cover,
                ),
          onTap: () async {
            String currentUserId =
                Provider.of<UserData>(context, listen: false).currentUserId;
            Post post = await DatabaseService.getUserPost(
              currentUserId,
              activity.postId,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentsScreen(
                  post: post,
                  likeCount: post.likeCount,
                  author: snapshot.data,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        title: Text(
          'Activity',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _setupActivities(),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _activities.length,
                itemBuilder: (BuildContext context, int index) {
                  Activity activity = _activities[index];
                  return _buildActivity(activity);
                },
              ),
      ),
    );
  }
}
