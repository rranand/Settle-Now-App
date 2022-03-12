import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/others/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorChooser extends StatefulWidget {
  const ColorChooser({ Key? key }) : super(key: key);

  @override
  _ColorChooserState createState() => _ColorChooserState();
}

class _ColorChooserState extends State<ColorChooser> {
  late SharedPreferences prefs;
  int red = 103;
  int green = 58;
  int blue = 183;
  int alpha = 255;
  Color dColor = Colors.deepPurple;
  bool changed = false;

  Future _init() async {
    prefs = await SharedPreferences.getInstance();
    red = Theme.of(context).primaryColor.red;
    green = Theme.of(context).primaryColor.green;
    blue = Theme.of(context).primaryColor.blue;
    alpha = Theme.of(context).primaryColor.alpha;

    if (prefs.getInt('alpha') != null) {
      alpha = prefs.getInt('alpha')!;
    } else {
      prefs.setInt('alpha', 255);
    }

    if (prefs.getInt('red') != null) {
      red = prefs.getInt('red')!;
    } else {
      prefs.setInt('red', 103);
    }

    if (prefs.getInt('green') != null) {
      green = prefs.getInt('green')!;
    } else {
      prefs.setInt('green', 58);
    }

    if (prefs.getInt('blue') != null) {
      blue = prefs.getInt('blue')!;
    } else {
      prefs.setInt('blue', 183);
    }

    if (this.mounted) {
      setState(() {
        dColor = Color.fromARGB(alpha, red, green, blue);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Colour",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final provider = Provider.of<ThemeProvider>(context, listen: false);
              provider.toggleTheme(!themeProvider.darkTheme);
              prefs.setBool('darkTheme', themeProvider.darkTheme);
            },
            icon: Icon(
              Icons.brightness_2,
              color: themeProvider.darkTheme?Colors.white:Colors.black87,
            )
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dColor,
                ),
                width: 120,
                height: 120,
              ),
              onTap: () {
                setState(() {
                  changed = false;
                });
                showDialog(
                  context: context, 
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), 
                          child: Container(
                            height: 625,
                            width: MediaQuery.of(context).size.width*0.95,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pick A Colour",
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  ColorPicker(
                                    labelTypes: [ColorLabelType.rgb],
                                    displayThumbColor: true,
                                    paletteType: PaletteType.hueWheel,
                                    pickerColor: dColor,
                                    onColorChanged: (_) {
                                      setState((){
                                        dColor = _;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width: 100,
                                      child: ElevatedButton(
                                        child: Text("Close", style: TextStyle(color: Colors.white),),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                      height: 45,
                                      width: 100,
                                      child: ElevatedButton(
                                        child: Text("Choose", style: TextStyle(color: Colors.white),),
                                        onPressed: () {
                                          changed = true;
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                      )
                                    )
                                  ]
                                  ),
                                ],
                              ),
                            )
                          )
                        );
                      },
                    );
                  }
                );
              }
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 103, 58, 183)
                    ),
                    onPressed: () {
                      setState(() {
                        red = 103;
                        green = 58;
                        blue = 183;
                        alpha = 255;
                      });
                        
                      prefs.setInt('red', red);
                      prefs.setInt('green', green);
                      prefs.setInt('blue', blue);
                      prefs.setInt('alpha', alpha);
                      final provider = Provider.of<ColorProvider>(context, listen: false);
                      provider.changeColor(Color.fromARGB(alpha, red, green, blue));
                    },
                    child: Text("Reset Color", style: TextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(width: 20,),
                SizedBox(
                  width: 120,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      if (changed) {
                        changed = false;
                        prefs.setInt('red', dColor.red);
                        prefs.setInt('green', dColor.green);
                        prefs.setInt('blue', dColor.blue);
                        prefs.setInt('alpha', dColor.alpha);
                        final provider = Provider.of<ColorProvider>(context, listen: false);
                        provider.changeColor(dColor);
                      }
                    },
                    child: Text("Change Colour", style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}