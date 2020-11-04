import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/activity_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utilities/constants.dart';
import 'package:instagram/utilities/styles.dart';
import 'package:instagram/widgets/default_appBar_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  ActivityScreen({this.currentUserId});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
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
                        Text('commented: "${activity.comment}'),
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
                  currentUserId: widget.currentUserId,
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
      appBar: DefaultAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _setupActivities(),
        child: ListView.builder(
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
