import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';

import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';

import 'actions.dart';
import 'compandactvariables.dart';
import 'globalvars.dart';

class Gameview extends BaseGame {
  BuildContext context;
  bool isdebug;
  bool recordFps() => true;
  Gameview(this.context, {this.isdebug = false}) {
    initialize();
    bComponent = BComponent(context, isdebug: isdebug);

    if (bComponent == null) return;
    bComponent.initializeWorld();

    if (isdebug) {
      //
    }
    // add(Testing());
    //  add(Testing2());
    gameisdebug = isdebug;
  }

  @override
  bool debugMode() {
    // TODO: implement debugMode
    return super.debugMode();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
  }

  @override
  void render(Canvas canvas) {
    // print(cameragetcameracontroller().backgroundcolor);
    // return;
    double themargin = 20;
    if (bComponent == null) return;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        Paint()
          ..color = cameragetcameracontrollercore().backgroundcolor != null
              ? Color(cameragetcameracontrollercore().backgroundcolor)
              : Colors.blueGrey);

    // print(camera_getcameracontroller().backgroundcolor);

    bComponent.render(canvas);

    if (isdebug) {
      drawtext(canvas, "fps: " + fps(1).toStringAsFixed(0), themargin);

      if (getprojectsettingscore().usingmicrophone) {
        themargin = themargin + 20;
        drawtext(canvas, "microphone dblevel: $miclevel", themargin);
      }
      if (getprojectsettingscore().usinggyroscope) {
        themargin = themargin + 20;
        drawtext(
            canvas,
            "gyroscope x=${gyroscopevalue.x.toStringAsFixed(1)}, y=${gyroscopevalue.y.toStringAsFixed(1)}, z=${gyroscopevalue.z.toStringAsFixed(1)}",
            themargin);
      }
      if (getprojectsettingscore().usingaccelerometer) {
        themargin = themargin + 20;
        drawtext(
            canvas,
            "accelerometer x=${accelerometervalue.x.toStringAsFixed(1)}, y=${accelerometervalue.y.toStringAsFixed(1)}, z=${accelerometervalue.z.toStringAsFixed(1)}",
            themargin);
      }
      int b = 0;
      for (int a = 0; a < globalvariablescore.length; a++) {
        Clsvariable t = globalvariablescore[a];
        if (t is Clsvariablenumber) {
          if (t.showdebug == null || t.showdebug == true) {
            drawtext(canvas, "${t.name}: ${t.value}",
                (themargin * 1) + (20 * (b + 1)).toDouble());
            b++;
          }
        }
        if (t is Clsvariableboolean) {
          if (t.showdebug == null || t.showdebug == true) {
            drawtext(canvas, "${t.name}: ${t.value}",
                (themargin * 1) + (20 * (b + 1)).toDouble());
            b++;
          }
        }
        if (t is Clsvariabletext) {
          if (t.showdebug == null || t.showdebug == true) {
            drawtext(canvas, "${t.name}: ${t.value}",
                (themargin * 1) + (20 * (b + 1)).toDouble());
            b++;
          }
        }
      }
      for (int c = 0; c < bComponent.bodies.length; c++) {
        for (int a = 0;
            a < bComponent.bodies[c].thescript.localvariables.length;
            a++) {
          if (bComponent.bodies[c].isdestroyed == false) {
            Clsvariable t = bComponent.bodies[c].thescript.localvariables[a];
            if (t is Clsvariablenumber) {
              if (t.showdebug == null || t.showdebug == true) {
                drawtext(canvas, "${t.name}: ${t.value}",
                    (themargin * 1) + (20 * (b + 1)).toDouble());
                b++;
              }
            }
            if (t is Clsvariableboolean) {
              if (t.showdebug == null || t.showdebug == true) {
                drawtext(canvas, "${t.name}: ${t.value}",
                    (themargin * 1) + (20 * (b + 1)).toDouble());
                b++;
              }
            }
            if (t is Clsvariabletext) {
              if (t.showdebug == null || t.showdebug == true) {
                drawtext(canvas, "${t.name}: ${t.value}",
                    (themargin * 1) + (20 * (b + 1)).toDouble());
                b++;
              }
            }
          }
        }
      }

// for (int c = 0; c < gameobjectitemscore.length; c++) {
//         for (int a = 0;
//             a < gameobjectitemscore[c].getscript().localvariables.length;
//             a++) {
//           Clsvariable t = gameobjectitemscore[c].getscript().localvariables[a];
//           if (t is Clsvariablenumber) {
//             // print(t.name);
//             if (t.showdebug==null || t.showdebug==true) {
//               drawtext(canvas, "${t.name}: ${t.value}",
//                   (themargin * 1) + (20 * (b + 1)).toDouble());
//               b++;
//             }
//           }
//           if (t is Clsvariableboolean) {
//             if (t.showdebug==null || t.showdebug==true) {
//               drawtext(canvas, "${t.name}: ${t.value}",
//                   (themargin * 1) + (20 * (b + 1)).toDouble());
//               b++;
//             }
//           }
//           if (t is Clsvariabletext) {
//             if (t.showdebug==null || t.showdebug==true) {
//               drawtext(canvas, "${t.name}: ${t.value}",
//                   (themargin * 1) + (20 * (b + 1)).toDouble());
//               b++;
//             }
//           }
//         }
//       }

    }
  }

  void drawtext(Canvas canvas, String text, double top) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      shadows: <Shadow>[
        Shadow(
          offset: Offset(0, 0),
          blurRadius: 10,
          color: Colors.black,
        ),
      ],
    );

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 1000,
    );

    textPainter.paint(canvas, Offset(10, top));
  }

  @override
  void onAttach() {
    // TODO: implement onAttach

    super.onAttach();
  }

  @override
  void onDetach() {
    // TODO: implement onDetach
    if (actionsinitiator != null) {
      actionsinitiator.destroytimers();
    }

    super.onDetach();
  }

  @override
  void update(double t) {
    if (bComponent == null) return;

    bComponent.update(t);
  }

  @override
  void resize(Size size) {
    if (bComponent == null) return;

    bComponent.resize(size);
  }

  void onTouchDown(PointerDownEvent details) {
    if (bComponent == null) return;
    bComponent.ontouchdown(details);
  }

  void onTouchUp(PointerUpEvent details) {
    if (bComponent == null) return;
    bComponent.ontouchup(details);
  }

  void onTouchMove(PointerMoveEvent details) {
    if (bComponent == null) return;
    bComponent.ontouchmove(details);
  }

  void onJoystickDirectionChanged(Joystickvalues joystickvalues) {
    if (bComponent == null) return;
    bComponent.onjoystickdirectionchanged(joystickvalues);
  }

  void onButtonEvent(Buttonvalues buttonvalues) {
    if (bComponent == null) return;
    bComponent.onbuttonevent(buttonvalues);
  }
}
