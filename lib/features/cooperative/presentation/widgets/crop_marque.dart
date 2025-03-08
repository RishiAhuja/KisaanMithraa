import 'package:flutter/material.dart';

class CropMarquee extends StatefulWidget {
  final List<String> crops;
  final ThemeData theme;

  const CropMarquee({
    Key? key,
    required this.crops,
    required this.theme,
  }) : super(key: key);

  @override
  _CropMarqueeState createState() => _CropMarqueeState();
}

class _CropMarqueeState extends State<CropMarquee> {
  late ScrollController _scrollController;
  bool _scrollForward = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() async {
    if (!mounted) return;

    while (_scrollController.hasClients) {
      if (!mounted) break;

      await Future.delayed(Duration(milliseconds: 50));

      if (!_scrollController.hasClients) break;

      if (_scrollForward) {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 5) {
          _scrollForward = false;
        } else {
          _scrollController.animateTo(
            _scrollController.position.pixels + 2,
            duration: Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      } else {
        if (_scrollController.position.pixels <= 5) {
          _scrollForward = true;
        } else {
          _scrollController.animateTo(
            _scrollController.position.pixels - 2,
            duration: Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.only(bottom: 0),
      height: 50,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.crops.length,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final crop = widget.crops[index];
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(crop,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white)),
              labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              backgroundColor: widget.theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: widget.theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        },
      ),
    );
  }
}
