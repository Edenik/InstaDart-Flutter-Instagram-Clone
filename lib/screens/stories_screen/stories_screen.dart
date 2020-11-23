import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/stories_screen/widgets/animated_bar.dart';
import 'package:instagram/screens/stories_screen/widgets/story_info.dart';
import 'package:instagram/services/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StoryScreen extends StatefulWidget {
  final List<Story> stories;
  final User user;
  final int seenStories;
  const StoryScreen(
      {@required this.stories,
      @required this.user,
      @required this.seenStories});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animController;
  int _currentIndex = 0;
  DragStartDetails startVerticalDragDetails;
  DragUpdateDetails updateVerticalDragDetails;
  int _seenStories;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    setState(() => _seenStories = widget.seenStories);

    if (_seenStories != 0 && _seenStories != widget.stories.length) {
      _pageController = PageController(initialPage: _seenStories);
      setState(() => _currentIndex = _seenStories);
      _loadStory(story: widget.stories[_seenStories], animateToPage: false);
    } else {
      final Story firstStory = widget.stories.first;
      _loadStory(story: firstStory, animateToPage: false);
    }

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex++;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            // if the stories ended...
            Navigator.of(context).pop(_currentIndex);
            // _currentIndex = 0;
            // _loadStory(story: widget.stories[_currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragStart: (dragDetails) {
          startVerticalDragDetails = dragDetails;
        },
        onVerticalDragUpdate: (dragDetails) {
          updateVerticalDragDetails = dragDetails;
        },
        onVerticalDragEnd: (endDetails) {
          double dx = updateVerticalDragDetails.globalPosition.dx -
              startVerticalDragDetails.globalPosition.dx;
          double dy = updateVerticalDragDetails.globalPosition.dy -
              startVerticalDragDetails.globalPosition.dy;
          double velocity = endDetails.primaryVelocity;

          //Convert values to be positive
          if (dx < 0) dx = -dx;
          if (dy < 0) dy = -dy;

          if (velocity < 0) {
            //swipe Up
            _onSwipeUp();
          } else {
            //swipe down
            Navigator.of(context).pop(_currentIndex);
          }
        },
        onTapDown: (detailes) => _onTapDown(detailes),
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final Story story = widget.stories[index];

                StoriesService.setNewStoryView(currentUserId, story);

                return CachedNetworkImage(
                  imageUrl: story.imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 500),
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return Center(
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress),
                    );
                  },
                );
              },
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: [
                  Row(
                    children: widget.stories
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                              i,
                              AnimatedBar(
                                animationController: _animController,
                                position: i,
                                currentIndex: _currentIndex,
                              ));
                        })
                        .values
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 1.5, vertical: 10.0),
                    child: StoryInfo(
                      onSwipeUp: () => _onSwipeUp(),
                      height: size.height - 100,
                      user: widget.user,
                      story: widget.stories[_currentIndex],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onSwipeUp() async {
    if (widget.stories[_currentIndex].linkUrl != '') {
      String url = widget.stories[_currentIndex].linkUrl;
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          enableJavaScript: true,
        );
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    final Size screenSize = MediaQuery.of(context).size;
    final double dx = details.globalPosition.dx;

    if (dx < screenSize.width / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex--;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenSize.width / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex++;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          Navigator.of(context).pop(_currentIndex);
        }
      });
    } else {}
  }

  void _loadStory({Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    _animController.duration = Duration(seconds: story.duration ?? 10);
    _animController.forward();

    if (animateToPage) {
      _pageController.animateToPage(_currentIndex,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }
}
