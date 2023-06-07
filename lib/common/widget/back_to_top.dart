import 'package:flutter/material.dart';
import 'image/asset_image.dart';

typedef VoidCallback = void Function();

class BackToTop extends StatefulWidget {
  final ScrollController controller;

  const BackToTop(this.controller, {super.key});

  @override
  State<StatefulWidget> createState() => _BackToTopState();
}

class _BackToTopState extends State<BackToTop> {
  bool show = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(onScroll);
  }

  void onScroll() {
    setState(() {
      show = widget.controller.offset > MediaQuery.of(context).size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: show,
        child: SizedBox(
            width: 48,
            height: 48,
            child: FloatingActionButton(
              onPressed: () => widget.controller.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.linear),
              backgroundColor: Colors.white,
              child: assetImage('images/ic_back_top.png', 32, 32),
            )));
  }
}
