import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

class MachMainScreen extends StatefulWidget {
  const MachMainScreen({Key? key}) : super(key: key);

  @override
  State<MachMainScreen> createState() => _MachMainScreenState();
}

class _MachMainScreenState extends State<MachMainScreen> {
  bool _isAccessAllowed = false;

  CapturedData? _lastCapturedData;

  double x = 0.0;
  double y = 0.0;
  Offset lineStartOffset = const Offset(0, 0);
  Offset lineEndOffset = const Offset(0, 0);
  double circleRadius = 0.0;
  Offset _localPosition = Offset(0.0, 0.0);
  Offset _globalPosition = Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _isAccessAllowed = await ScreenCapturer.instance.isAccessAllowed();

    setState(() {});
  }

  void _handleClickCapture(CaptureMode mode) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String imageName = 'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
    String imagePath = '${directory.path}/screen_capturer_example/Screenshots/$imageName';
    _lastCapturedData = await ScreenCapturer.instance.capture(
      mode: mode,
      imagePath: imagePath,
      silent: true,
    );
    if (_lastCapturedData != null) {
      // ignore: avoid_print
      // print(_lastCapturedData!.toJson());
    } else {
      // ignore: avoid_print
      print('User canceled capture');
    }
    setState(() {});
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  final List<Widget> _stackLine = [];

  addLine() {
    _stackLine.add(
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        top: 0,
        child: CustomPaint(
          // painter: LinePainter(
          //   startOffset: lineStartOffset,
          //   endOffset: lineEndOffset,
          // ),
          // painter: RectanglePainter(
          //   startOffset: lineStartOffset,
          //   endOffset: lineEndOffset,
          // ),
          painter: CirclePainter(
            center: lineStartOffset,
            radius: circleRadius,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return fui.PlatformMenuBar(
      menus: const [
        fui.PlatformMenuItemGroup(members: [
          fui.PlatformMenuItem(
            label: "테스트",
          )
        ]),
        fui.PlatformMenuItemGroup(members: [
          fui.PlatformMenuItem(
            label: "테스트2",
          ),
          fui.PlatformMenuItem(
            label: "테스트2",
          )
        ])
      ],
      child: Scaffold(
        body: Column(
          children: [
            fui.CommandBar(
              primaryItems: [
                fui.CommandBarBuilderItem(
                  builder: (context, mode, w) => Tooltip(
                    message: "Create something new!",
                    child: w,
                  ),
                  wrappedItem: fui.CommandBarButton(
                    icon: const Icon(fui.FluentIcons.add),
                    label: const Text('New'),
                    onPressed: () {
                      setState(() {
                        _stackLine.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: fui.Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_lastCapturedData != null && _lastCapturedData?.imagePath != null)
                    MouseRegion(
                      // opaque: true,
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        print("[onEnter] $event");
                      },
                      onExit: (event) {
                        print("[onExit] $event");
                      },
                      onHover: _updateLocation,
                      child: GestureDetector(
                        onPanStart: (details) {
                          print("[onPanDown] localPosition ${details.localPosition}");
                          print("[onPanDown] globalPosition ${details.globalPosition}");
                          setState(() {
                            _localPosition = details.localPosition;
                            _globalPosition = details.globalPosition;

                            lineStartOffset = Offset(
                              details.localPosition.dx,
                              details.localPosition.dy - 15,
                            );
                            lineEndOffset = Offset(
                              details.localPosition.dx,
                              details.localPosition.dy - 15,
                            );
                            circleRadius = 0.0;
                          });
                        },
                        onPanEnd: (details) {
                          print("[onPanEnd] ${details}");
                          addLine();
                        },
                        onPanCancel: () {
                          print("[onPanCancel] ");
                        },
                        onPanUpdate: (details) {
                          print("[onPanUpdate] ${details.localPosition} | x: ${details.delta.dx}"
                              "y: ${details.delta.dy}");

                          RenderBox? object = context.findRenderObject() as RenderBox?;
                          print(object?.globalToLocal(details.globalPosition));

                          setState(() {
                            _localPosition = details.localPosition;
                            _globalPosition = details.globalPosition;

                            // lineEndOffset = details.localPosition;
                            // print();
                            double rad = _localPosition.distance - lineStartOffset.distance;
                            if(rad <= 0) {
                              rad = 0;
                            }
                            circleRadius = rad;
                            lineEndOffset = Offset(
                              details.localPosition.dx,
                              details.localPosition.dy - 15,
                            );
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          // width: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                top: 0,
                                child: fui.Container(
                                  decoration: BoxDecoration(border: Border.all()),
                                  child: Image.file(
                                    File(_lastCapturedData!.imagePath!),
                                    fit: BoxFit.scaleDown,
                                    // fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                top: 0,
                                child: Stack(
                                  children: _stackLine,
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                top: 0,
                                child: CustomPaint(
                                  painter: CirclePainter(
                                    center: lineStartOffset,
                                    radius: circleRadius,
                                  ),
                                  // painter: RectanglePainter(
                                  //   startOffset: lineStartOffset,
                                  //   endOffset: lineEndOffset,
                                  // ),
                                  // painter: LinePainter(
                                  //   startOffset: lineStartOffset,
                                  //   endOffset: lineEndOffset,
                                  // ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Column(
                                  children: [
                                    Text(
                                      'The cursor is here: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
                                    ),
                                    Text("_localPosition: x: ${_localPosition.dx}, y: ${_localPosition.dy}"),
                                    Text("_globalPosition: x: ${_globalPosition.dx}, y: ${_globalPosition.dy}")
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      _handleClickCapture(CaptureMode.region);
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    iconSize: 48,
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

class LinePainter extends CustomPainter {
  Offset? startOffset;
  Offset? endOffset;

  LinePainter({this.startOffset, this.endOffset});

  @override
  void paint(fui.Canvas canvas, fui.Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..color = Colors.red
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      startOffset ?? Offset(0, 0),
      endOffset ?? Offset(0, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant fui.CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class RectanglePainter extends CustomPainter {
  Offset? startOffset;
  Offset? endOffset;

  RectanglePainter({this.startOffset, this.endOffset});

  @override
  void paint(fui.Canvas canvas, fui.Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    final rect = Rect.fromPoints(
      startOffset ?? Offset(0, 0),
      endOffset ?? Offset(0, 0),
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant fui.CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class CirclePainter extends CustomPainter {
  Offset? center;
  double? radius;

  CirclePainter({this.center, this.radius});

  @override
  void paint(fui.Canvas canvas, fui.Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center ?? Offset(0, 0), radius ?? 0.0, paint);
  }

  @override
  bool shouldRepaint(covariant fui.CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
