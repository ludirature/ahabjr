import 'dart:io';

import 'package:expressions/expressions.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/box2d/viewport.dart' as v;
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';

import 'package:flutter/material.dart';
// import 'package:mobilegameengine/gamecore/lib/compandactvariables.dart';

import 'compandactvariables.dart';
import 'globalvars.dart';
import 'package:box2d_flame/box2d.dart';

import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:math' as math;

Actionsinitiator actionsinitiator = Actionsinitiator();
BComponent bComponent;

Size screensize;

Vector2 touchmovelocation = Vector2(0, 0);
Vector2 touchdownlocation = Vector2(0, 0);
Vector2 touchuplocation = Vector2(0, 0);
Offset touchdownlocationphysical = Offset(0, 0);
Offset touchmovelocationphysical = Offset(0, 0);
Offset touchuplocationphysical = Offset(0, 0);

MyContactListener contactListener;
double deltatime = 0.0;

Map<String, dynamic> uijoystickvalues = Map();

class Cameraproperties {
  double x = 0;
  double y = 0;
  double scale = 0;
  Cameraproperties(x, y, scale);
}

Cameraproperties currentcamerasettings;

class MyContactListener extends ContactListener {
  //Box2d Object collision detection listener
  List<Gameobject> bodies = List();
  MyContactListener(this.bodies);
  // Map<String, dynamic> contactlist = Map();
  List<Contact> contactlists2 = List();
  @override
  void beginContact(Contact contact) {
    //when object collision detected then add to lists contactlists2
    contactlists2.add(contact);
    // print(contact.fixtureA.userData.toString()    + "           " + contact.fixtureB.userData.toString());
    // print();
  }

  bool iscolliding(String object1, String object2, Gameobject thegameobject) {
    //check if object1 and object2 is colliding. goindex is gameobject index used for unique id if gameobjects have the same name
    for (int a = 0; a < contactlists2.length; a++) {
      Map<String, dynamic> userdataA = contactlists2[a].fixtureA.userData;
      Map<String, dynamic> userdataB = contactlists2[a].fixtureB.userData;

      if (object1 == userdataA['objectname'] &&
          thegameobject.bodyindex == userdataA['bodyindex']) {
        if (object2 == userdataB['objectname']) {
//  print("        ");
//       print("        ");
//       print("        ");
//       print(object1 + "  " + userdataA['objectname']);
//       print(thegameobject.bodyindex.toString() + "      " + userdataA['bodyindex'].toString());
//       print(object2 + "    " + userdataB['objectname']);
//       print("        ");
//       print("        ");
//       print("        ");
          return true;
        }
      }
      if (object1 == userdataB['objectname'] &&
          thegameobject.bodyindex == userdataB['bodyindex']) {
        if (object2 == userdataA['objectname']) {
          return true;
        }
      }
    }

    return false;
  }

  bool isnaa(String object, Gameobject thegameobject) {
    for (int a = 0; a < contactlists2.length; a++) {
      Map<String, dynamic> userdataA = contactlists2[a].fixtureA.userData;
      Map<String, dynamic> userdataB = contactlists2[a].fixtureB.userData;
      if (object == userdataA['objectname'] &&
          thegameobject.bodyindex == userdataA['bodyindex']) {
        return true;
      }

      if (object == userdataB['objectname'] &&
          thegameobject.bodyindex == userdataB['bodyindex']) {
        return true;
      }
    }
    return false;
  }

  @override
  void endContact(Contact contact) {
    contactlists2.remove(
        contact); //when objects end colliding then remove from contactlists
  }

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}

class Actionsinitiator {
  final World world;
  final v.Viewport viewport;

  Box2DComponent box2d;

  BuildContext context;

  List<Gameobject> bodies = List();
  bool isended = false;

  double camerasmoothx = double.nan;
  double camerasmoothy = double.nan;
  double camerasmoothscale = double.nan;

  Actionsinitiator(
      {this.box2d, this.context, this.world, this.bodies, this.viewport}) {}

  void destroytimers() {
    for (int a = 0; a < gameobjectitemscore.length; a++) {
      for (int b = 0;
          b < gameobjectitemscore[a].getscript().components.length;
          b++) {
        Clsscriptitem t = gameobjectitemscore[a].getscript().components[b];
        if (t is Clsacttimerdelayed) {
          t.stop();
          t.iscancelled = true;
        }
        if (t is Clsacttimerperiodic) {
          t.stop();
          t.iscancelled = true;
        }
      }
    }
  }

  void getchildactions(String curobjectname, Clsscriptitem si, int goindex,
      Gameobject thegameobject) {
    if (isended) {
      return;
    }

    int childindex = si.getchildindex();
    initiateactions4(t: si, goindex: goindex, thegameobject: thegameobject);

    if (si is Clsactiscollidingwith) {
      checkiscollidingwith(
          curobjectname, si.objectname, si, goindex, thegameobject);
    } else if (si is Clsactiscardinal) {
      checkiscardinal(curobjectname, si, goindex, thegameobject);
    } else if (si is Clsactbooleanexpression) {
      checkbooleanexpression(curobjectname, si, goindex, thegameobject);
    } else if (si is Clsacttimerdelayed) {
      checkistimerdelayed(curobjectname, si, goindex, thegameobject);
    } else if (si is Clsacttimerperiodic) {
      checkistimerperiodic(curobjectname, si, goindex, thegameobject);
    } else if (si is Clsactsavevalue) {
      checkissavevalue(curobjectname, si, goindex, thegameobject);
    } else if (si is Clsactloadvalue) {
      checkisloadvalue(curobjectname, si, goindex, thegameobject);
    }
    if (childindex != -1) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[childindex];

      getchildactions(curobjectname, si2, goindex, thegameobject);
    }
  }

  void checkiscollidingwith(String curobjectname, String objectname,
      Clsscriptitem si, int goindex, Gameobject thegameobject) {
    int trueindex = si.gettrueindex();
    int falseindex = si.getfalseindex();

    if (trueindex == null && falseindex == null) return;

    bool iscollisiontrue =
        contactListener.iscolliding(curobjectname, objectname, thegameobject);

    if (trueindex != -1 && iscollisiontrue) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[trueindex];

      getchildactions(curobjectname, si2, goindex, thegameobject);
    }
    if (falseindex != -1 && !iscollisiontrue) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[falseindex];

      getchildactions(curobjectname, si2, goindex, thegameobject);
    }
  }

  void checkiscardinal(String curobjectname, Clsscriptitem si, int goindex,
      Gameobject thegameobject) {
    int trueindex = si.gettrueindex();
    int falseindex = si.getfalseindex();

    if (trueindex == null && falseindex == null) return;

    Clsactiscardinal thet = si;

    double theangle = 0;

    if (!thet.angle.isNaN || thet.expangle != null) {
      if (thet.expangle == null) {
        theangle = thet.angle;
      } else {
        double r = evaluateexpression(thet.expangle, thegameobject);
        theangle = r;
      }
    }

    bool iscardinal = checkifcardinal(theangle, thet.direction);

    if (trueindex != -1 && iscardinal) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[trueindex];

      getchildactions(curobjectname, si2, goindex, thegameobject);
    }
    if (falseindex != -1 && !iscardinal) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[falseindex];

      getchildactions(curobjectname, si2, goindex, thegameobject);
    }
  }

  void checkbooleanexpression(String curobjectname, Clsscriptitem si,
      int goindex, Gameobject thegameobject) {
    int trueindex = si.gettrueindex();
    int falseindex = si.getfalseindex();

    if (trueindex == null && falseindex == null) return;
    bool isexpressiontrue = false;
    if (si is Clsactbooleanexpression) {
      if (si.expexpression != null) {
        isexpressiontrue = evaluateexpression(si.expexpression, thegameobject);
      }
    }
    if (trueindex != -1 && isexpressiontrue) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[trueindex];

      getchildactions(curobjectname, si2, goindex, thegameobject);
    }
    if (falseindex != -1 && !isexpressiontrue) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[falseindex];

      getchildactions(curobjectname, si2, goindex, thegameobject);
    }
  }

  void checkistimerdelayed(String curobjectname, Clsscriptitem si, int goindex,
      Gameobject thegameobject) {
    int asyncindex = si.getasyncindex();
    if (asyncindex != -1) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[asyncindex];

      if (si is Clsacttimerdelayed) {
        // if (bodyindex < bodies.length) {
        si.start(() {
          getchildactions(curobjectname, si2, goindex, thegameobject);
        });
        // }
      }
    }
  }

  void checkistimerperiodic(String curobjectname, Clsscriptitem si, int goindex,
      Gameobject thegameobject) {
    int asyncindex = si.getasyncindex();
    if (asyncindex != -1) {
      Clsscriptitem si2 =
          gameobjectitemscore[goindex].getscript().components[asyncindex];

      if (si is Clsacttimerperiodic) {
        si.start(() {
          getchildactions(curobjectname, si2, goindex, thegameobject);
        });
      }
    }
  }

  void checkissavevalue(String curobjectname, Clsscriptitem si, int goindex,
      Gameobject thegameobject) {
    int asyncindex = si.getasyncindex();

    if (si is Clsactsavevalue) {
      String filename = si.filename;
      String variable = si.variable;
      if (filename != null) {
        if (variable != null) {
          File variablefile = File(variablespath + "/" + filename);
          String thevariable = variable;
          Map<String, dynamic> content = Map();
          for (int indvar = 0; indvar < globalvariablescore.length; indvar++) {
            Clsvariable t2 = globalvariablescore[indvar];
            if (t2 is Clsvariablenumber) {
              if (t2.name == thevariable) {
                content = {"type": "number", "value": t2.value};
              }
            }
            if (t2 is Clsvariabletext) {
              if (t2.name == thevariable) {
                content = {"type": "text", "value": t2.value};
              }
            }
            if (t2 is Clsvariableboolean) {
              if (t2.name == thevariable) {
                content = {"type": "boolean", "value": t2.value};
              }
            }
          }

          variablefile.writeAsString(json.encode(content)).then((onValue) {
            if (asyncindex != -1) {
              Clsscriptitem si2 = gameobjectitemscore[goindex]
                  .getscript()
                  .components[asyncindex];
              getchildactions(curobjectname, si2, goindex, thegameobject);
            }
          });
        }
      }
    }
  }

  void checkisloadvalue(String curobjectname, Clsscriptitem si, int goindex,
      Gameobject thegameobject) {
    int asyncindex = si.getasyncindex();

    if (si is Clsactloadvalue) {
      String filename = si.filename;
      String variable = si.variable;
      if (filename != null) {
        if (variable != null) {
          File variablefile = File(variablespath + "/" + filename);
          // variablefile.deleteSync();
          if (!variablefile.existsSync()) {
            variablefile.writeAsStringSync(json.encode({"empty": "empty"}));
          }
          variablefile.readAsString().then((onValue) {
            String thevariable = variable;

            Map<String, dynamic> tojson2 = json.decode(onValue);

            String thetype = tojson2['type'];

            if (thetype == "number") {
              for (int indvar = 0;
                  indvar < globalvariablescore.length;
                  indvar++) {
                Clsvariable t2 = globalvariablescore[indvar];
                if (t2 is Clsvariablenumber) {
                  if (t2.name == thevariable) {
                    t2.value = tojson2['value'];
                  }
                }
              }
            }

            if (thetype == "boolean") {
              for (int indvar = 0;
                  indvar < globalvariablescore.length;
                  indvar++) {
                Clsvariable t2 = globalvariablescore[indvar];
                if (t2 is Clsvariableboolean) {
                  if (t2.name == thevariable) {
                    t2.value = tojson2['value'];
                  }
                }
              }
            }
            if (thetype == "text") {
              for (int indvar = 0;
                  indvar < globalvariablescore.length;
                  indvar++) {
                Clsvariable t2 = globalvariablescore[indvar];
                if (t2 is Clsvariabletext) {
                  if (t2.name == thevariable) {
                    t2.value = tojson2['value'];
                  }
                }
              }
            }

            if (asyncindex != -1) {
              Clsscriptitem si2 = gameobjectitemscore[goindex]
                  .getscript()
                  .components[asyncindex];
              getchildactions(curobjectname, si2, goindex, thegameobject);
            }
          });
        }
      }
    }
  }

  bool checkscreentouchlocation(Clscompscreenontouch si) {
    if (si.touchevent == "Touch Down") {
      if (si.location == "Whole") {
        return true;
      } else if (si.location == "Right") {
        if (touchdownlocationphysical.dx >
            screensize.width - screensize.width / 2) {
          return true;
        }
      } else if (si.location == "Left") {
        if (touchdownlocationphysical.dx < screensize.width / 2) {
          return true;
        }
      } else if (si.location == "Top") {
        if (touchdownlocationphysical.dy < screensize.height / 2) {
          return true;
        }
      } else if (si.location == "Bottom") {
        if (touchdownlocationphysical.dy >
            screensize.height - screensize.height / 2) {
          return true;
        }
      }
    }
    if (si.touchevent == "Touch Up") {
      if (si.location == "Whole") {
        return true;
      } else if (si.location == "Right") {
        if (touchuplocationphysical.dx >
            screensize.width - screensize.width / 2) {
          return true;
        }
      } else if (si.location == "Left") {
        if (touchuplocationphysical.dx < screensize.width / 2) {
          return true;
        }
      } else if (si.location == "Top") {
        if (touchuplocationphysical.dy < screensize.height / 2) {
          return true;
        }
      } else if (si.location == "Bottom") {
        if (touchuplocationphysical.dy >
            screensize.height - screensize.height / 2) {
          return true;
        }
      }
    }
    if (si.touchevent == "Touch Move") {
      if (si.location == "Whole") {
        return true;
      } else if (si.location == "Right") {
        if (touchmovelocationphysical.dx >
            screensize.width - screensize.width / 2) {
          return true;
        }
      } else if (si.location == "Left") {
        if (touchmovelocationphysical.dx < screensize.width / 2) {
          return true;
        }
      } else if (si.location == "Top") {
        if (touchmovelocationphysical.dy < screensize.height / 2) {
          return true;
        }
      } else if (si.location == "Bottom") {
        if (touchmovelocationphysical.dy >
            screensize.height - screensize.height / 2) {
          return true;
        }
      }
    }
    return false;
  }

  void initiateactions(
      {int goindex,
      Gameobject thegameobject,
      Eevents eevents,
      String variablename}) {
    String curobjectname = gameobjectitemscore[goindex].getgameobject().name;
    for (int b = 0;
        b < gameobjectitemscore[goindex].getscript().components.length;
        b++) {
      Clsscriptitem si = gameobjectitemscore[goindex].getscript().components[b];
      if (si is Clscompscreenontouch) {
        if (si.touchevent == "Touch Down" &&
            eevents == Eevents.screentouchdown &&
            checkscreentouchlocation(si)) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
        if (si.touchevent == "Touch Down" &&
            eevents == Eevents.screentouchdowncontinuous &&
            checkscreentouchlocation(si)) {
          if (thegameobject.istouchdown == true && si.continuous == "true") {
            getchildactions(curobjectname, si, goindex, thegameobject);
          }
        }
        if (si.touchevent == "Touch Up" &&
            eevents == Eevents.screentouchup &&
            checkscreentouchlocation(si)) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
        if (si.touchevent == "Touch Move" &&
            eevents == Eevents.screentouchmove &&
            checkscreentouchlocation(si)) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
      } else if (si is Clscompstep) {
        if (eevents == Eevents.step) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
      } else if (si is Clscomponobjectloaded) {
        if (eevents == Eevents.onobjectloaded) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
      } else if (si is Clscompobjectontouch) {
        if (si.touchevent == "Touch Down" &&
            eevents == Eevents.objecttouchdown) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
        if (si.touchevent == "Touch Up" && eevents == Eevents.objecttouchup) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
        if (si.touchevent == "Touch Move" &&
            eevents == Eevents.objecttouchmove) {
          getchildactions(curobjectname, si, goindex, thegameobject);
        }
      } else if (si is Clscomponjoystick) {
        if (si.joystickevent == "Direction Changed" &&
            eevents == Eevents.onjoystickdirectionchanged) {
          if (si.variable == variablename) {
            getchildactions(curobjectname, si, goindex, thegameobject);
          }
        }
      }
    }
  }

  dynamic evaluateexpression(String expressions, Gameobject thegameobject) {
    Expression expression = Expression.parse(expressions.replaceAll(" ", ""));
  // print(expressions);
    Map<String, dynamic> context = {
      "position_x": thegameobject.body.position.x,
      "position_y": thegameobject.body.position.y,
      "angle": thegameobject.body.getAngle(),
      "scale_x": thegameobject.transformprop.sx,
      "scale_y": thegameobject.transformprop.sy,
      "velocity_x": thegameobject.body.linearVelocity.x,
      "velocity_y": thegameobject.body.linearVelocity.y,
      "velocity_angle": thegameobject.body.angularVelocity,
     
      "camera_width": getprojectsettingscore().appversion >= 11
          ? screensize.width
          : viewport.size.width,
      "camera_height": getprojectsettingscore().appversion >= 11
          ? screensize.height
          : viewport.size.height,
      "camera_x": viewport.translation.x,
      "camera_y": viewport.translation.y,
      "touchmove_x": touchmovelocation.x == null ? 0 : touchmovelocation.x,
      "touchmove_y": touchmovelocation.y == null ? 0 : touchmovelocation.y,
      "touchdown_x": touchdownlocation.x == null ? 0 : touchdownlocation.x,
      "touchdown_y": touchdownlocation.y == null ? 0 : touchdownlocation.y,
      "touchup_x": touchuplocation.x == null ? 0 : touchuplocation.x,
      "touchup_y": touchuplocation.y == null ? 0 : touchuplocation.y,
      "mic_dblevel": miclevel,
      "accelerometer_x": accelerometervalue.x,
      "accelerometer_y": accelerometervalue.y,
      "accelerometer_z": accelerometervalue.z,
      "gyroscope_x": gyroscopevalue.x,
      "gyroscope_y": gyroscopevalue.y,
      "gyroscope_z": gyroscopevalue.z,
      "deltatime": deltatime
    };
    if(thegameobject.compsprite!=null){
      context.addAll({"sprite_opacity": thegameobject.compsprite.opacity});
    }

  
    for (int a2 = 0; a2 < globalvariablescore.length; a2++) {
      Clsvariable t2 = globalvariablescore[a2];
      if (t2 is Clsvariablenumber) {
        context.addAll({t2.name: t2.value});
      }
      if (t2 is Clsvariableboolean) {
        context.addAll({t2.name: t2.value});
      }
    }
    for (int b2 = 0; b2 < thegameobject.thescript.localvariables.length; b2++) {
      Clsvariable t2 = thegameobject.thescript.localvariables[b2];
      if (t2 is Clsvariablenumber) {
        context.addAll({t2.name: t2.value});
      }
      if (t2 is Clsvariableboolean) {
        context.addAll({t2.name: t2.value});
      }
    }

    uijoystickvalues.forEach((key, value) {
      context.addAll({key + "_angle": value["angle"]});
      context.addAll({key + "_distance": value["distance"]});
      context.addAll({key + "_value_x": value["valx"]});
      context.addAll({key + "_value_y": value["valy"]});
    });
    expressionmathvariables(context);

    final evaluator = const ExpressionEvaluator();
    var r = evaluator.eval(expression, context);
    if (r is int) {
      return r.toDouble();
    } else if (r is double) {
      return r;
    } else {
      return r;
    }
  }

  void initiateactions4(
      {Clsscriptitem t, Gameobject thegameobject, int goindex}) {
    if (t is Clsactloadscene) {
      if (t.scenename == null) return;
      actionsinitiator.isended = true;
      for (int a1 = 0; a1 < soundslistscore.length; a1++) {
        Clscompsound t = soundslistscore[a1];
        t.stop();
      }
      destroytimers();

      loadprojectcore2(t.scenename).then((onValue) {
        bComponent.bodies.forEach((val) {
          bComponent.remove(val);
        });
        bComponent.bodies.clear();
        bodies.clear();

        bComponent.initializeWorld();
        actionsinitiator.isended = false;
        refreshuicomponents();
      });

      return;
    }

    if (t is Clsactsetvelocity) {
      if (thegameobject.body.getType() != BodyType.STATIC) {
        if (!t.x.isNaN || t.expx != null) {
          if (t.expx == null) {
            thegameobject.body
              ..linearVelocity.x = t.x
              ..setAwake(true);
          } else {
            double r = evaluateexpression(t.expx, thegameobject);
            thegameobject.body
              ..linearVelocity.x = r
              ..setAwake(true);
          }
        }

        if (!t.y.isNaN || t.expy != null) {
          if (t.expy == null) {
            thegameobject.body
              ..linearVelocity.y = t.y
              ..setAwake(true);
          } else {
            double r = evaluateexpression(t.expy, thegameobject);
            thegameobject.body
              ..linearVelocity.y = r
              ..setAwake(true);
          }
        }
        if (!t.angular.isNaN || t.expangular != null) {
          if (t.expangular == null) {
            thegameobject
              ..body.angularVelocity = t.angular
              ..isapplyingangular = true
              ..anglelimit = t.anglelimit
              ..defangle = thegameobject.body.getAngle();
          } else {
            double r = evaluateexpression(t.expangular, thegameobject);
            thegameobject
              ..body.angularVelocity = r
              ..isapplyingangular = true
              ..anglelimit = t.anglelimit
              ..defangle = thegameobject.body.getAngle();
          }

          thegameobject.body.setAwake(true);
        }
      }
    } else if (t is Clsactsettransform) {
      if (!t.x.isNaN || t.expx != null) {
        if (t.expx == null) {
          thegameobject.body.setTransform(
              Vector2(t.x, thegameobject.body.position.y),
              thegameobject.body.getAngle());
          thegameobject.transformprop.x = t.x;
          // print("asdfasdfasdf");
        } else {
          double r = evaluateexpression(t.expx, thegameobject);
          thegameobject.body.setTransform(
              Vector2(r, thegameobject.body.position.y),
              thegameobject.body.getAngle());
          thegameobject.transformprop.x = r;
        }
      }

      if (!t.y.isNaN || t.expy != null) {
        if (t.expy == null) {
          thegameobject.body.setTransform(
              Vector2(thegameobject.body.position.x, t.y),
              thegameobject.body.getAngle());
          thegameobject.transformprop.y = -t.y;
        } else {
          double r = evaluateexpression(t.expy, thegameobject);
          thegameobject.body.setTransform(
              Vector2(thegameobject.body.position.x, r),
              thegameobject.body.getAngle());
          thegameobject.transformprop.y = -r;
        }
      }

      if (!t.angle.isNaN || t.expangle != null) {
        // print("asdfasdfasdf");
        if (t.expangle == null) {
          thegameobject.body.setTransform(
              Vector2(
                  thegameobject.body.position.x, thegameobject.body.position.y),
              -t.angle);
          thegameobject.transformprop.angle = t.angle;
        } else {
          double r = evaluateexpression(t.expangle, thegameobject);
          thegameobject.body.setTransform(
              Vector2(
                  thegameobject.body.position.x, thegameobject.body.position.y),
              -r);
          thegameobject.transformprop.angle = r;
        }
        // print(bodies[a].body.getAngle());
      }

      if (!t.sy.isNaN || t.expsy != null) {
        if (t.expsy == null) {
          // gameobjectitemscore[goindex].settransform(sy: t.sy);
          thegameobject.transformprop.sy = t.sy;
        } else {
          double r = evaluateexpression(t.expsy, thegameobject);
          // gameobjectitemscore[goindex].settransform(sy: r);
          thegameobject.transformprop.sy = r;
        }
      }

      if (!t.sx.isNaN || t.expsx != null) {
        if (t.expsx == null) {
          // gameobjectitemscore[goindex].settransform(sx: t.sx);
          thegameobject.transformprop.sx = t.sx;
        } else {
          double r = evaluateexpression(t.expsx, thegameobject);
          // gameobjectitemscore[goindex].settransform(sx: r);
          thegameobject.transformprop.sx = r;
        }
      }
    } else if (t is Clsactsetcamera) {
      double posx = 0;
      double posy = 0;
      double scale = 1;
      if (!t.posx.isNaN || t.expposx != null) {
        posx = t.posx;

        if (t.expposx == null) {
        } else {
          double r = evaluateexpression(t.expposx, thegameobject);

          posx = r;
        }
      }

      if (!t.posy.isNaN || t.expposy != null) {
        if (t.expposy == null) {
          posy = t.posy;
        } else {
          double r = evaluateexpression(t.expposy, thegameobject);

          posy = r;
        }
      }

      if (!t.scale.isNaN || t.expscale != null) {
        if (t.expscale == null) {
          scale = t.scale;
          // print(scale);
        } else {
          double r = evaluateexpression(t.expscale, thegameobject);
          scale = r;
        }
      }

      double smoothvalue = 0;

      if (!t.smoothvalue.isNaN) {
        smoothvalue = t.smoothvalue;

        if (t.posx != null) {
          if (camerasmoothx.isNaN) {
            camerasmoothx = cameragetcameracontrollercore().x;
          }

          camerasmoothx =
              ui.lerpDouble(camerasmoothx, posx, smoothvalue * deltatime);
          cameragetcameracontrollercore().x = camerasmoothx;
          // viewport.setCamera(camerasmoothx, posy, scale);
        }

        if (t.posy != null) {
          if (camerasmoothy.isNaN) {
            camerasmoothy = cameragetcameracontrollercore().y;
          }

          camerasmoothy =
              ui.lerpDouble(camerasmoothy, posy, smoothvalue * deltatime);
          cameragetcameracontrollercore().y = -camerasmoothy;
        }

        if (t.scale != null) {
          if (camerasmoothscale.isNaN) {
            camerasmoothscale = cameragetcameracontrollercore().scale;
          }
          camerasmoothscale =
              ui.lerpDouble(camerasmoothscale, scale, smoothvalue * deltatime);
          cameragetcameracontrollercore().scale = camerasmoothscale;
        }
      } else {
        // viewport.setCamera(posx, posy, scale);
        // print(posx);
        cameragetcameracontrollercore().x = posx;
        cameragetcameracontrollercore().y = -posy;
        cameragetcameracontrollercore().scale = scale;
      }
      //  print(viewport.x);

    } else if (t is Clsactsetsprite) {
      String image = t.image;
      String animation = t.animation;
      double opacity = t.opacity;
      if (opacity != null) {
        thegameobject.compsprite.opacity = opacity;
      }
      if (image != null) {
        thegameobject.compsprite.imagepath = image;
        thegameobject.compsprite.spriteanimation = null;
        thegameobject.updatesprite();
      } else {
        if (animation != null) {
          thegameobject.compsprite.imagepath = null;
          thegameobject.compsprite.spriteanimation = t.animation;
          thegameobject.updatesprite();
        }
      }
    } else if (t is Clsactdestroyobject) {
      // if (a < bodies.length) {

      thegameobject.destroyobject(thegameobject, "bcomponent");
      // bodies[a].destroyobject("bodies");

      // if (a >= gameobjectitemscore.length) {
      //   //
      //   // bComponent.bodies.removeAt(a);
      // }
      // }
    } else if (t is Clsactcreateobject) {
      //  print("asdfasdfasdf");
      for (int indcreate = 0;
          indcreate < gameobjectitemscore.length;
          indcreate++) {
        if (t.objectname ==
            gameobjectitemscore[indcreate].getgameobject().name) {
          Gameobject temp = Gameobject(
              box2d, context, indcreate, bodies.length, t.objectname,
              isdebug: bodies[indcreate].isdebug);
//  print(temp.objectname);
          bodies.add(temp);

          box2d.add(temp);

          double posx = 0;
          double posy = 0;
          double velx = 0;
          double vely = 0;
          if (!t.x.isNaN || t.expx != null) {
            if (t.expx == null) {
              posx = t.x;
            } else {
              double r = evaluateexpression(t.expx, thegameobject);
              posx = r;
            }
          }

          if (!t.y.isNaN || t.expy != null) {
            if (t.expy == null) {
              posy = t.y;
            } else {
              double r = evaluateexpression(t.expy, thegameobject);
              posy = r;
            }
          }

          if (!t.velx.isNaN || t.expvelx != null) {
            if (t.expvelx == null) {
              velx = t.velx;
            } else {
              double r = evaluateexpression(t.expvelx, thegameobject);
              velx = r;
            }
          }

          if (!t.vely.isNaN || t.expvely != null) {
            if (t.expvely == null) {
              vely = t.vely;
            } else {
              double r = evaluateexpression(t.expvely, thegameobject);
              vely = r;
            }
          }

          if (t.isrelative) {
            Offset temprotation = rotatepoint(
                thegameobject.body.position.x,
                thegameobject.body.position.y,
                thegameobject.body.getAngle(),
                Offset(thegameobject.body.position.x + posx,
                    thegameobject.body.position.y + posy));

            temp.body.setTransform(Vector2(0, 0), temp.body.getAngle());

            Offset temprotation2 = rotatepoint(
                temp.body.position.x,
                temp.body.position.y,
                thegameobject.body.getAngle(),
                Offset(
                    temp.body.position.x + velx, temp.body.position.y + vely));

            temp.body.setTransform(Vector2(temprotation.dx, temprotation.dy),
                temp.body.getAngle());

            temp.body.linearVelocity =
                Vector2(temprotation2.dx, temprotation2.dy);
          } else {
            temp.body.setTransform(Vector2(posx, posy), temp.body.getAngle());
            temp.body.linearVelocity = Vector2(velx, vely);
          }

          temp.onloaded();
          break;
        }
      }
    } else if (t is Clsactfollowobject) {
      double x1 = thegameobject.body.position.x;
      double y1 = thegameobject.body.position.y;

      for (int indcreate = 0; indcreate < bodies.length; indcreate++) {
        if (t.objectname == bodies[indcreate].objectname &&
            !bodies[indcreate].isdestroyed) {
          double x2 = bodies[indcreate].body.position.x;
          double y2 = bodies[indcreate].body.position.y;

          double distance =
              math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
          double movex = (x2 - x1) / distance;
          double movey = (y2 - y1) / distance;
          double tempgetangle = thegameobject.body.getAngle();
          if (!thegameobject.comprigidbody.fixedrotation) {
            tempgetangle = math.atan2(y2 - y1, x2 - x1);
          }

          thegameobject.body.setTransform(Vector2(x1, y1), tempgetangle);

          double speed = 0;
          if (!t.speed.isNaN || t.expspeed != null) {
            if (t.expspeed == null) {
              speed = t.speed;
            } else {
              double r = evaluateexpression(t.expspeed, thegameobject);
              speed = r;
            }
          }
          if (!t.speed.isNaN) {
            thegameobject.body.linearVelocity =
                Vector2(movex * speed, movey * speed);
          }

          break;
        }
      }
    } else if (t is Clsactsettext) {
      if (t.text != null) {
        thegameobject.comptext.text = t.text;
      } else if (t.exptext != null) {
        String thevariable = t.exptext;

        for (int indvar = 0; indvar < globalvariablescore.length; indvar++) {
          Clsvariable t2 = globalvariablescore[indvar];
          if (t2 is Clsvariablenumber) {
            if (t2.name == thevariable) {
              if (isInteger(t2.value)) {
                thegameobject.comptext.text = t2.value.toStringAsFixed(0);
              } else {
                thegameobject.comptext.text = t2.value.toStringAsFixed(2);
              }
            }
          }
        }
      }
      if (!t.blurradius.isNaN) {
        thegameobject.comptext.blurradius = t.blurradius;
      }
      if (t.fontfamily != null) {
        thegameobject.comptext.fontfamily = t.fontfamily;
      }
      // print(t.fontsize);
      if (!t.fontsize.isNaN) {
        thegameobject.comptext.fontsize = t.fontsize;
      }
      if (t.textcolor != null) {
        thegameobject.comptext.textcolor = t.textcolor;
      }
    } else if (t is Clsactsetvariable) {
      if (!t.numbervalue.isNaN || t.expnumbervalue != null) {
       
        if (t.expnumbervalue == null) {
           
          if (t.scope == "global" || t.scope == null) {
            for (int indvar = 0;
                indvar < globalvariablescore.length;
                indvar++) {
              Clsvariable t2 = globalvariablescore[indvar];
              if (t2 is Clsvariablenumber) {
                if (t2.name == t.variablename) {
                  t2.value = t.numbervalue;
                }
              }
            }
          }

          if (t.scope == "local") {
            for (int indvar = 0;
                indvar < thegameobject.thescript.localvariables.length;
                indvar++) {
              Clsvariable t2 = thegameobject.thescript.localvariables[indvar];
              if (t2 is Clsvariablenumber) {
                if (t2.name == t.variablename) {
                  t2.value = t.numbervalue;
                }
              }
            }
          }
        } else {
         
          double r = evaluateexpression(t.expnumbervalue, thegameobject);
//  print(r);
          if (t.scope == "global" || t.scope == null) {

            for (int indvar = 0;
                indvar < globalvariablescore.length;
                indvar++) {
              Clsvariable t2 = globalvariablescore[indvar];
               
              if (t2 is Clsvariablenumber) {
               
                if (t2.name == t.variablename) {
                  t2.value = r;
                }
              }
            }
          }
          if (t.scope == "local") {
            for (int indvar = 0;
                indvar < thegameobject.thescript.localvariables.length;
                indvar++) {
              Clsvariable t2 = thegameobject.thescript.localvariables[indvar];
              if (t2 is Clsvariablenumber) {
                // print(thegameobject.goindex);
                if (t2.name == t.variablename) {
                  t2.value = r;
                }
              }
            }
          }
        }
      }
      if (t.booleanvalue != null) {
        if (t.scope == "global" || t.scope == null) {
          for (int indvar = 0; indvar < globalvariablescore.length; indvar++) {
            Clsvariable t2 = globalvariablescore[indvar];
            if (t2 is Clsvariableboolean) {
              if (t2.name == t.variablename) {
                t2.value = t.booleanvalue;
              }
            }
          }
        }
        if (t.scope == "local") {
          for (int indvar = 0;
              indvar < thegameobject.thescript.localvariables.length;
              indvar++) {
            Clsvariable t2 = thegameobject.thescript.localvariables[indvar];
            if (t2 is Clsvariableboolean) {
              if (t2.name == t.variablename) {
                t2.value = t.booleanvalue;
              }
            }
          }
        }
      }
      if (t.textvalue != null) {
        if (t.scope == "global" || t.scope == null) {
          for (int indvar = 0; indvar < globalvariablescore.length; indvar++) {
            Clsvariable t2 = globalvariablescore[indvar];
            if (t2 is Clsvariabletext) {
              if (t2.name == t.variablename) {
                t2.value = t.textvalue;
              }
            }
          }
        }
        if (t.scope == "local") {
          for (int indvar = 0;
              indvar < thegameobject.thescript.localvariables.length;
              indvar++) {
            Clsvariable t2 = thegameobject.thescript.localvariables[indvar];
            if (t2 is Clsvariabletext) {
              if (t2.name == t.variablename) {
                t2.value = t.textvalue;
              }
            }
          }
        }
      }
    } else if (t is Clsactsetsound) {
      for (int indsounds = 0; indsounds < soundslistscore.length; indsounds++) {
        Clscompsound t2 = soundslistscore[indsounds];
        if (t2.variablename == t.variablename) {
          if (!t.volume.isNaN || t.expvolume != null) {
            if (t.expvolume == null) {
              t2.setvolume(t.volume);
            } else {
              double r = evaluateexpression(t.expvolume, thegameobject);

              t2.setvolume(r);
            }
          }
          if (t.playerstate == "playing") {
            t2.play();
          }
          if (t.playerstate == "paused") {
            t2.pause();
          }
        }
      }
    }
  }
}

class Gameobject extends BodyComponent {
  // bool isimageresolved = false;
  ui.Image theimage;
  int goindex;
  BuildContext context;
  double tempy = 0;
  bool ismanaapply = false;
  bool isapplyingangular = false;
  double anglelimit = 0;
  double defangle = 0;
  int bodyindex = 0;
  bool isdestroyed = false;
  String objectname = "";
  Spriteanimation sp;
  Clscomptransform transformprop;
  Clscomptext comptext;
  String firstimage;
  Clscompsprite compsprite;
  Clscomprigidbody comprigidbody;
  Clscompboxcollider compboxcollider;
  Clscompcirclecollider compcirclecollider;
  Clscompgameobject thegameobject;
  Clscompscript thescript;

  bool isdebug;
  bool istouchdown = false;
  bool hasrigidbody = false;
  bool isloaded = false;

  Gameobject(Box2DComponent box, this.context, this.goindex, this.bodyindex,
      this.objectname,
      {this.isdebug = false})
      : super(box) {
    theimage = noimage;
    if (gameobjectitemscore[goindex].getsprite() != null) {
      compsprite = gameobjectitemscore[goindex].getsprite();
      if (gameobjectitemscore[goindex].getsprite().imagepath == null) {
        String spriteanimationvariable =
            gameobjectitemscore[goindex].getsprite().spriteanimation;

        if (spriteanimationvariable != null) {
          firstimage = gameobjectitemscore[goindex]
              .getspriteanimationimage(spriteanimationvariable);
          if (firstimage != null) {
            if (loadedimages.length > 0) {
              theimage = loadedimages[firstimage];

              sp = Spriteanimation(
                  id: goindex.toString(),
                  images: gameobjectitemscore[goindex]
                      .getspriteanimationimagelists(spriteanimationvariable),
                  interval: gameobjectitemscore[goindex]
                      .getspriteanimationimageinterval(
                          spriteanimationvariable));
            }
          }
        }
      } else {
        theimage =
            loadedimages[gameobjectitemscore[goindex].getsprite().imagepath];
      }
    }

    transformprop = Clscomptransform(
        x: gameobjectitemscore[goindex].gettransform().x,
        y: gameobjectitemscore[goindex].gettransform().y,
        sx: gameobjectitemscore[goindex].gettransform().sx,
        sy: gameobjectitemscore[goindex].gettransform().sy);

    if (gameobjectitemscore[goindex].gettext() != null) {
      comptext = gameobjectitemscore[goindex].gettext();
    }
    if (gameobjectitemscore[goindex].getrigidbody() != null) {
      comprigidbody = gameobjectitemscore[goindex].getrigidbody();
    }
    if (gameobjectitemscore[goindex].getboxcollider() != null) {
      compboxcollider = gameobjectitemscore[goindex].getboxcollider();
    }
    if (gameobjectitemscore[goindex].getcirclecollider() != null) {
      compcirclecollider = gameobjectitemscore[goindex].getcirclecollider();
    }
    thegameobject = gameobjectitemscore[goindex].getgameobject();
    thescript = Clscompscript.fromJson(
        gameobjectitemscore[goindex].getscript().toJson());
    createBody();
  }

  void updatesprite() {
    theimage = noimage;
    sp = null;
    if (compsprite.imagepath == null) {
      String spriteanimationvariable = compsprite.spriteanimation;

      if (spriteanimationvariable != null) {
        firstimage = gameobjectitemscore[goindex]
            .getspriteanimationimage(spriteanimationvariable);

        if (firstimage != null) {
          if (loadedimages.length > 0) {
            theimage = loadedimages[firstimage];

            sp = Spriteanimation(
                id: goindex.toString(),
                images: gameobjectitemscore[goindex]
                    .getspriteanimationimagelists(spriteanimationvariable),
                interval: gameobjectitemscore[goindex]
                    .getspriteanimationimageinterval(spriteanimationvariable));
          }
        }
      }
    } else {
      theimage = loadedimages[compsprite.imagepath];
      // print(compsprite.imagepath);
    }
  }

  void ontouchup(PointerUpEvent details) {
    // print("asdfasdfasdfasdfasdf");
    // print(objectname);
    if (isdestroyed) return;
    istouchdown = false;
    actioninitiator(eevents: Eevents.screentouchup);
    if (hasrigidbody) {
      if (body.getFixtureList() != null) {
        bool wasTouched = body.getFixtureList().testPoint(this
            .viewport
            .getScreenToWorld(
                Vector2(details.localPosition.dx, details.localPosition.dy)));
        if (wasTouched) {
          actioninitiator(eevents: Eevents.objecttouchup);
        }
      }
    } else {
      if (compboxcollider != null) {
        double x =
            (transformprop.x + compboxcollider.x - (compboxcollider.w / 2)) +
                screensize.width / 2;
        double y =
            (transformprop.y + compboxcollider.y - (compboxcollider.h / 2)) +
                screensize.height / 2;
        double w = compboxcollider.w;
        double h = compboxcollider.h;

        Vector2 touchpos =
            ((Vector2(details.localPosition.dx, details.localPosition.dy)));

        if (touchpos.x > x && touchpos.x < x + w) {
          if (touchpos.y > y && touchpos.y < y + h) {
            actioninitiator(eevents: Eevents.objecttouchup);
          }
        }
      }
    }
  }

  void ontouchdown(PointerDownEvent details) {
    if (isdestroyed) return;
    istouchdown = true;

    actioninitiator(eevents: Eevents.screentouchdown);
    if (hasrigidbody) {
      if (body.getFixtureList() != null) {
        // print(objectname);
        bool wasTouched = body.getFixtureList().testPoint(this
            .viewport
            .getScreenToWorld(
                Vector2(details.localPosition.dx, details.localPosition.dy)));
        if (wasTouched) {
          actioninitiator(eevents: Eevents.objecttouchdown);
        }
      }
    } else {
      if (compboxcollider != null) {
        double x =
            (transformprop.x + compboxcollider.x - (compboxcollider.w / 2)) +
                screensize.width / 2;
        double y =
            (transformprop.y + compboxcollider.y - (compboxcollider.h / 2)) +
                screensize.height / 2;
        double w = compboxcollider.w;
        double h = compboxcollider.h;

        Vector2 touchpos =
            ((Vector2(details.localPosition.dx, details.localPosition.dy)));

        if (touchpos.x > x && touchpos.x < x + w) {
          if (touchpos.y > y && touchpos.y < y + h) {
            actioninitiator(eevents: Eevents.objecttouchdown);
          }
        }
      }
    }
  }

  void ontouchmove(PointerMoveEvent details) {
    if (isdestroyed) return;
    actioninitiator(eevents: Eevents.screentouchmove);
    if (hasrigidbody) {
      if (body.getFixtureList() != null) {
        bool wasTouched = body.getFixtureList().testPoint(this
            .viewport
            .getScreenToWorld(
                Vector2(details.localPosition.dx, details.localPosition.dy)));
        if (wasTouched) {
          actioninitiator(eevents: Eevents.objecttouchmove);
        }
      }
    } else {
      if (compboxcollider != null) {
        double x =
            (transformprop.x + compboxcollider.x - (compboxcollider.w / 2)) +
                screensize.width / 2;
        double y =
            (transformprop.y + compboxcollider.y - (compboxcollider.h / 2)) +
                screensize.height / 2;
        double w = compboxcollider.w;
        double h = compboxcollider.h;

        Vector2 touchpos =
            ((Vector2(details.localPosition.dx, details.localPosition.dy)));

        if (touchpos.x > x && touchpos.x < x + w) {
          if (touchpos.y > y && touchpos.y < y + h) {
            actioninitiator(eevents: Eevents.objecttouchmove);
          }
        }
      }
    }
  }

  void onbuttonevent(Buttonvalues buttonvalues) {
    print(buttonvalues.variable + "                " + buttonvalues.event);
  }

  void onuijoystickdirectionchanged(Joystickvalues joystickvalues) {
    if (isdestroyed) return;

    uijoystickvalues.update(
        joystickvalues.variable,
        (value) => {
              "angle": joystickvalues.angle,
              "distance": joystickvalues.distance,
              "valx": joystickvalues.valx,
              "valy": joystickvalues.valy
            },
        ifAbsent: () => {
              "angle": joystickvalues.angle,
              "distance": joystickvalues.distance,
              "valx": joystickvalues.valx,
              "valy": joystickvalues.valy
            });
    actioninitiator(
        eevents: Eevents.onjoystickdirectionchanged,
        variablename: joystickvalues.variable);
  }

  void onupdate(double t) {
    if (isdestroyed) return;
    if (isloaded == false) return;
    actioninitiator(eevents: Eevents.step);
    if (istouchdown) {
      actioninitiator(eevents: Eevents.screentouchdowncontinuous);
    }

    if (sp != null) {
      sp.update(t);
      theimage = loadedimages[sp.getcurrentimagepath()];
    }
  }

  void destroyobject(Gameobject thegameobject2, String where) {
    isdestroyed = true;
    // world.destroyBody(this.body);
    this.body.setActive(false);
    this.body.setAwake(false);
    // bComponent.remove(this);

    if (where == "bodies" && bodyindex >= gameobjectitemscore.length) {
      // actionsinitiator.bodies.removeAt(bodyindex);
    }
    if (where == "bcomponent" && bodyindex >= gameobjectitemscore.length) {
      bComponent.bodies.remove(thegameobject2);
      // bComponent.bodies.removeAt(bodyindex);
      // print(bodyindex);
    }

    destroy();
  }

  @override
  bool destroy() {
    return super.destroy();
  }

  @override
  void onDestroy() {
    super.onDestroy();
  }

  void onloaded() {
    if (isdestroyed) return;
    actioninitiator(eevents: Eevents.onobjectloaded);
    isloaded = true;
  }

  void actioninitiator({Eevents eevents, String variablename}) {
    actionsinitiator.initiateactions(
        goindex: goindex,
        // bodyindex: bodyindex,
        thegameobject: this,
        eevents: eevents,
        variablename: variablename);
  }

  @override
  void update(double t) {
    if (isdestroyed) return;
    if (isapplyingangular) {
      if (this.body.angularVelocity > 0) {
        if (-this.body.getAngle() < anglelimit) {
          isapplyingangular = false;
          this.body.angularVelocity = 0;
          this.body.setTransform(this.body.position, -anglelimit);
        }
      }
      if (this.body.angularVelocity < 0) {
        if (-this.body.getAngle() > anglelimit) {
          isapplyingangular = false;
          this.body.angularVelocity = 0;
          this.body.setTransform(this.body.position, -anglelimit);
        }
      }
    }

    super.update(t);
  }

  @override
  void renderChain(Canvas canvas, List<Offset> points) {}

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    // if (!isimageresolved) {
    //   return;
    // }

    if (isdebug) {
      if (contactListener.isnaa(objectname, this)) {
        final Paint paint = Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(center, radius, paint);
      } else {
        final Paint paint = Paint()
          ..color = Colors.lightBlueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(center, radius, paint);
      }
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);

    canvas.rotate(-this.body.getAngle());
    canvas.scale(transformprop.sx, transformprop.sy);

    if (compsprite != null && thegameobject.isactive == "true") {
      double w = compsprite.w * viewport.scale;
      double h = compsprite.h * viewport.scale;
      canvas.drawImageNine(
          theimage,
          Rect.fromCenter(center: Offset(0, 0), width: 0, height: 0),
          Rect.fromCenter(
              center: Offset(
                  -gameobjectitemscore[goindex].getcirclecollider().x /
                      transformprop.sx,
                  -gameobjectitemscore[goindex].getcirclecollider().y /
                      transformprop.sy),
              width: w,
              height: h),
          Paint()
            ..color = Color.fromRGBO(0, 0, 0, compsprite.opacity)
            ..filterQuality = getimagequality());
    }

    if (comptext != null) {
      drawtext(canvas);
    }
    canvas.restore();
  }

  FilterQuality getimagequality() {
    if (getprojectsettingscore() == null) {
      return FilterQuality.low;
    }
    if (getprojectsettingscore().imagequality == "very low") {
      return FilterQuality.none;
    }
    if (getprojectsettingscore().imagequality == "low") {
      return FilterQuality.low;
    }
    if (getprojectsettingscore().imagequality == "medium") {
      return FilterQuality.medium;
    }
    if (getprojectsettingscore().imagequality == "high") {
      return FilterQuality.high;
    }
    return FilterQuality.none;
  }

  @override
  void renderPolygon(ui.Canvas canvas, List<ui.Offset> points) {
    canvas.save();

    canvas.translate(
        ((points[0].dx + points[2].dx + points[3].dx + points[1].dx) / 4),
        (points[0].dy + points[3].dy + points[2].dy + points[1].dy) / 4);

    canvas.rotate(-this.body.getAngle());
    canvas.scale(transformprop.sx, transformprop.sy);
    // print(theimage);
    if (compsprite != null && thegameobject.isactive == "true") {
      double w = compsprite.w * viewport.scale;
      double h = compsprite.h * viewport.scale;
      canvas.drawImageNine(
          theimage,
          Rect.fromCenter(center: Offset(0, 0), width: 0, height: 0),
          Rect.fromCenter(
              center: Offset(
                  -gameobjectitemscore[goindex].getboxcollider().x /
                      (transformprop.sx) *
                      viewport.scale,
                  -gameobjectitemscore[goindex].getboxcollider().y /
                      (transformprop.sy) *
                      viewport.scale),
              width: w,
              height: h),
          Paint()
            ..color = Color.fromRGBO(0, 0, 0, compsprite.opacity)
            ..filterQuality = getimagequality());
    }

    if (comptext != null) {
      drawtext(canvas);
    }
    canvas.restore();
    //  print(isdebug);
    if (isdebug) {
      final path = Path()..addPolygon(points, true);
      if (contactListener.isnaa(objectname, this)) {
        final Paint paint = Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawPath(path, paint);
      } else {
        final Paint paint = Paint()
          ..color = Colors.lightBlueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  void render(ui.Canvas canvas) {
    // print(isdestroyed);
    if (isdestroyed) return;

    try {
      if (gameobjectitemscore[goindex].getrigidbody() != null) {
        super.render(canvas);
        return;
      }
    } catch (error) {
      return;
    }

    canvas.save();
// print(getprojectsettingscore().appversion);
    if (getprojectsettingscore() != null &&
        getprojectsettingscore().appversion >= 11) {
      canvas.translate(
          (this.body.position.x +
              (gameobjectitemscore[goindex].gettransform().x) * viewport.scale +
              MediaQuery.of(context).size.width / 2),
          -this.body.position.y +
              (gameobjectitemscore[goindex].gettransform().y) * viewport.scale +
              MediaQuery.of(context).size.height / 2);
      canvas.rotate(transformprop.angle);
    } else {
      canvas.translate(
          (this.body.position.x +
              (gameobjectitemscore[goindex].gettransform().x) * viewport.scale +
              MediaQuery.of(context).size.width / 2),
          -this.body.position.y +
              (gameobjectitemscore[goindex].gettransform().y) * viewport.scale +
              MediaQuery.of(context).size.height / 2);
      canvas.rotate(gameobjectitemscore[goindex].gettransform().angle);
    }

    double w = 50;
    double h = 50;
    canvas.scale(transformprop.sx, transformprop.sy);
    if (compsprite != null && thegameobject.isactive == "true") {
      w = compsprite.w * viewport.scale;
      h = compsprite.h * viewport.scale;

      canvas.drawImageNine(
          theimage,
          Rect.fromCenter(center: Offset(0, 0), width: 0, height: 0),
          Rect.fromCenter(center: Offset(0, 0), width: w, height: h),
          Paint()
            ..color = Color.fromRGBO(0, 0, 0, compsprite.opacity)
            ..filterQuality = getimagequality());
    }

    if (comptext != null) {
      drawtext(canvas);
    }
    canvas.restore();

    if (isdebug) {
      canvas.save();

      canvas.translate(
          (this.body.position.x +
              (gameobjectitemscore[goindex].gettransform().x) * viewport.scale +
              MediaQuery.of(context).size.width / 2),
          -this.body.position.y +
              (gameobjectitemscore[goindex].gettransform().y) * viewport.scale +
              MediaQuery.of(context).size.height / 2);

      if (getprojectsettingscore().appversion >= 11) {
        canvas.rotate(transformprop.angle);
      } else {
        canvas.rotate(gameobjectitemscore[goindex].gettransform().angle);
      }

      if (compboxcollider != null) {
        final path = Path()
          ..addRect(Rect.fromLTWH(
              -(compboxcollider.w / 2) + compboxcollider.x,
              -(compboxcollider.h / 2) + compboxcollider.y,
              compboxcollider.w,
              compboxcollider.h));

        final Paint paint = Paint()
          ..color = Colors.lightBlueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawPath(path, paint);
      }
    }
    canvas.restore();
  }

  void drawtext(Canvas canvas) {
    final textStyle = TextStyle(
      color: Color(comptext.textcolor),
      fontFamily: comptext.fontfamily,
      fontSize: comptext.fontsize * viewport.scale,
      fontWeight: FontWeight.bold,
      // wordSpacing: 100*scale,
      shadows: <Shadow>[
        Shadow(
          offset: Offset(0, 0),
          blurRadius: comptext.blurradius,
          color: Colors.black87,
        ),
      ],
    );

    final textSpan = TextSpan(
      text: comptext.text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: comptext.width * viewport.scale,
    );

    textPainter.paint(
        canvas,
        Offset(-comptext.width * viewport.scale / 2,
            -comptext.height * viewport.scale / 2));
  }

  void createRevolutejoint(Body a, Body b, Clscomprevolutejoint revolutejoint) {
    final revolutejointdef = RevoluteJointDef();
    revolutejointdef.bodyA = a;
    revolutejointdef.bodyB = b;
    revolutejointdef.localAnchorA
        .setFrom(Vector2(revolutejoint.mainx, revolutejoint.mainy));
    revolutejointdef.localAnchorB
        .setFrom(Vector2(revolutejoint.objectx, revolutejoint.objecty));

    world.createJoint(revolutejointdef);
  }

  void createWheeljoint(Body a, Body b, Clscompwheeljoint wheeljoint) {
    final wheeljointdef = WheelJointDef();
    wheeljointdef.bodyA = a;
    wheeljointdef.bodyB = b;
    wheeljointdef.localAxisA.setFrom(Vector2(1, 1));
    wheeljointdef.localAnchorA.setFrom(Vector2(
        wheeljoint.mainx - compboxcollider.x,
        wheeljoint.mainy + compboxcollider.y));
    wheeljointdef.localAnchorB
        .setFrom(Vector2(wheeljoint.objectx, wheeljoint.objecty));

    wheeljointdef.dampingRatio = wheeljoint.dampingRatio;
    wheeljointdef.frequencyHz = wheeljoint.frequency;

    world.createJoint(wheeljointdef);
  }

  void createPrismaticJoint(Body a, Body b) {
    final pjdef = PrismaticJointDef();
    // pjdef.bodyA = a;
    // pjdef.bodyB = b;

    pjdef.initialize(a, b, Vector2(0, 0), Vector2(0, 0));
    // pjdef.bodyA = a;pjdef.bodyB=b;
    pjdef.lowerTranslation = 0;
    pjdef.upperTranslation = 0;
    pjdef.enableMotor = true;
    pjdef.motorSpeed = 20.5;
    pjdef.maxMotorForce = 10;
    // wheeljoint.type = JointType.WHEEL;
    // wheeljoint.dampingRatio =  0.1;
    // wheeljoint.frequencyHz = 3;

    world.createJoint(pjdef);
  }

  void createBody() {
    if (gameobjectitemscore[goindex].getrigidbody() != null) {
      hasrigidbody = true;
      final fixtureDef = FixtureDef();
      final bodyDef = BodyDef();
      if (gameobjectitemscore[goindex].getlastcollider() == "box") {
        final shape = new PolygonShape();
        double x = gameobjectitemscore[goindex].getboxcollider().x +
            gameobjectitemscore[goindex].gettransform().x;
        double y = gameobjectitemscore[goindex].getboxcollider().y +
            gameobjectitemscore[goindex].gettransform().y;

        double bcw = gameobjectitemscore[goindex].getboxcollider().w + 0.001;
        double bch = gameobjectitemscore[goindex].getboxcollider().h + 0.001;
        double tangle = gameobjectitemscore[goindex].gettransform().angle;

        Offset thep = Offset(0, 0);

        thep = rotatepoint(
            gameobjectitemscore[goindex].gettransform().x,
            gameobjectitemscore[goindex].gettransform().y,
            tangle,
            Offset(x, y));

        shape.setAsBox(bcw / 2, bch / 2, Vector2(0, 0), 0);

        fixtureDef.shape = shape;
        bodyDef.setPosition(Vector2(thep.dx, -thep.dy));

        bodyDef.setAngle(-tangle);
      }

      if (gameobjectitemscore[goindex].getlastcollider() == "circle") {
        double x = gameobjectitemscore[goindex].getcirclecollider().x +
            gameobjectitemscore[goindex].gettransform().x;
        double y = gameobjectitemscore[goindex].getcirclecollider().y +
            gameobjectitemscore[goindex].gettransform().y;
        double tangle = gameobjectitemscore[goindex].gettransform().angle;
        final shape = new CircleShape();
        Offset thep = Offset(0, 0);
        shape.radius = gameobjectitemscore[goindex].getcirclecollider().radius;
        thep = rotatepoint(
            gameobjectitemscore[goindex].gettransform().x,
            gameobjectitemscore[goindex].gettransform().y,
            tangle,
            Offset(x, y));

        fixtureDef.shape = shape;
        // fixtureDef  . =true;
        if (comprigidbody.issensor == true) {
          fixtureDef.isSensor = true;
        }
        bodyDef.setPosition(Vector2(thep.dx, -thep.dy));

        bodyDef.setAngle(-tangle);
      }

      fixtureDef.userData = {
        "objectname": gameobjectitemscore[goindex].getgameobject().name,
        "bodyindex": bodyindex
      };
      // print(goindex);

      fixtureDef.restitution =
          gameobjectitemscore[goindex].getrigidbody().bounciness;
      fixtureDef.friction =
          gameobjectitemscore[goindex].getrigidbody().friction;

      if (gameobjectitemscore[goindex].getrigidbody().bodytype == "static") {
        bodyDef.type = BodyType.STATIC;
      }
      if (gameobjectitemscore[goindex].getrigidbody().bodytype == "dynamic") {
        bodyDef.type = BodyType.DYNAMIC;
      }
      if (gameobjectitemscore[goindex].getrigidbody().bodytype == "kinematic") {
        bodyDef.type = BodyType.KINEMATIC;
      }

      bodyDef.setFixedRotation(
          gameobjectitemscore[goindex].getrigidbody().fixedrotation);

      fixtureDef.density = gameobjectitemscore[goindex].getrigidbody().density;
      if (comprigidbody.issensor == true) {
        fixtureDef.isSensor = true;
      }
      bodyDef.gravityScale =
          gameobjectitemscore[goindex].getrigidbody().gravityscale;

      Body groundBody = world.createBody(bodyDef);

      groundBody.createFixtureFromFixtureDef(fixtureDef);

      this.body = groundBody;
    } else {
      final bodyDef = BodyDef();
      Body groundBody = world.createBody(bodyDef);

      this.body = groundBody;
    }
  }
}

class BComponent extends Box2DComponent {
  BuildContext context;
  BComponent(this.context, {this.isdebug = false}) : super(scale: 1.0);
  List<Gameobject> bodies = List();
  bool isdebug;
  // Vector2 getcamera;

  @override
  void initializeWorld() {
    currentcamerasettings = Cameraproperties(0, 0, 1);
    actionsinitiator = Actionsinitiator(
        box2d: this, context: this.context, world: world, viewport: viewport);

    for (int a = 0; a < gameobjectitemscore.length; a++) {
      // if (gameobjectitemscore[a].getgameobject().isactive != "false") {
      Gameobject temp = Gameobject(this, context, a, bodies.length,
          gameobjectitemscore[a].getgameobject().name,
          isdebug: isdebug);

      bodies.add(temp);

      add(temp);

      actionsinitiator.bodies = bodies;
      // }
    }

    for (int a = 0; a < gameobjectitemscore.length; a++) {
      for (int b = 0; b < gameobjectitemscore[a].components.length; b++) {
        Clscomponent t = gameobjectitemscore[a].components[b];
        if (t is Clscomprevolutejoint) {
          for (int c = 0; c < bodies.length; c++) {
            if (bodies[c].objectname == t.object) {
              bodies[a].createRevolutejoint(bodies[a].body, bodies[c].body, t);
              break;
            }
          }
        }
        if (t is Clscompwheeljoint) {
          for (int c = 0; c < bodies.length; c++) {
            if (bodies[c].objectname == t.object) {
              bodies[a].createWheeljoint(bodies[a].body, bodies[c].body, t);
              break;
            }
          }
        }
      }
    }

    for (int a = 0; a < bodies.length; a++) {
      // for(int b=0;b<bodies[a].)
      // if (bodies[a].objectname == "body") {
      //   //  print("asdfasdf");
      //   // bodies[a].createRevolutejoints(bodies[a].body, bodies[0].body);
      //   // bodies[a].createRevolutejoints2(bodies[a].body, bodies[1].body);
      // }
      bodies[a].onloaded();
    }

    // print(bodies.length);
    contactListener = MyContactListener(bodies);
    world.setContactListener(contactListener);
  }

  @override
  void resize(ui.Size size) {
    screensize = (size);
    // print(screensize);

    super.resize(size);
  }

  @override
  void update(double t) {
    super.update(t);
    deltatime = t;
    Clscompcameracontroller cameracontroller = cameragetcameracontrollercore();

    this.viewport.scale = cameracontroller.scale;
    this.viewport.translation =
        Vector2(-cameracontroller.x, cameracontroller.y);
    bool isnaaycamerafollow = false;
    try {
      for (int a = 0; a < bodies.length; a++) {
        if (!bodies[a].isdestroyed) {
          if (cameracontroller.objecttofollow ==
              gameobjectitemscore[bodies[a].goindex].getgameobject().name) {
            cameraFollow(bodies[a],
                horizontal: cameracontroller.h, vertical: cameracontroller.v);
            isnaaycamerafollow = true;
            break;
          }
        }
      }
      for (int a = 0; a < bodies.length; a++) {
        if (!bodies[a].isdestroyed) {
          bodies[a].onupdate(t);
        }
      }
    } catch (error) {}
    if (isnaaycamerafollow == false) {
      // viewport.setCamera(currentcamerasettings.x, currentcamerasettings.y, 1);
      // print(currentcamerasettings.x);
    }
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
  }

  void ontouchdown(PointerDownEvent details) {
    touchdownlocation = viewport.getScreenToWorld(
        Vector2(details.localPosition.dx, details.localPosition.dy));
    touchdownlocationphysical = details.localPosition;
    touchmovelocation = viewport.getScreenToWorld(
        Vector2(details.localPosition.dx, details.localPosition.dy));
    touchmovelocationphysical = details.localPosition;
    for (int a = 0; a < bodies.length; a++) {
      bodies[a].ontouchdown(details);
    }
  }

  void ontouchup(PointerUpEvent details) {
    touchuplocationphysical = details.localPosition;
    touchuplocation = viewport.getScreenToWorld(
        Vector2(details.localPosition.dx, details.localPosition.dy));

    for (int a = 0; a < bodies.length; a++) {
      // print("asdfasdf");
      bodies[a].ontouchup(details);
    }
  }

  void ontouchmove(PointerMoveEvent details) {
    touchmovelocation = viewport.getScreenToWorld(
        Vector2(details.localPosition.dx, details.localPosition.dy));

    touchmovelocationphysical = details.localPosition;
    for (int a = 0; a < bodies.length; a++) {
      bodies[a].ontouchmove(details);
    }
  }

  void onjoystickdirectionchanged(Joystickvalues joystickvalues) {
    for (int a = 0; a < bodies.length; a++) {
      bodies[a].onuijoystickdirectionchanged(joystickvalues);
    }
  }

  void onbuttonevent(Buttonvalues buttonvalues) {
    for (int a = 0; a < bodies.length; a++) {
      bodies[a].onbuttonevent(buttonvalues);
    }
  }
}

Offset rotatepoint(double cx, double cy, double angle, Offset p) {
  return Offset(
      math.cos(angle) * (p.dx - cx) - math.sin(angle) * (p.dy - cy) + cx,
      math.sin(angle) * (p.dx - cx) + math.cos(angle) * (p.dy - cy) + cy);
}
