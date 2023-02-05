import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/sampleWidget/room.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class onBoardingData {
  String title;
  String body;
  List<Widget> widgets;
  List<String> ImageText;
  int bottomIndex;

  onBoardingData(
      {required this.title,
      required this.body,
      required this.widgets,
      required this.ImageText,
      required this.bottomIndex});
}

class onBoarding extends StatefulWidget {
  final String version;
  const onBoarding({Key? key, required this.version}) : super(key: key);

  @override
  State<onBoarding> createState() => _onBoardingState();
}

class _onBoardingState extends State<onBoarding> {
  final pageController = PageController();
  int pageIndex = 0;
  bool isLastPage = false;
  List<onBoardingData> data = [];
  late SharedPreferences prefs;

  contextBuilder(BuildContext) {
    data.add(onBoardingData(
        title: "Room",
        body:
            "Create your personalised room to split bills according to people and then send the room key to everyone, so that everyone could join the room.",
        widgets: [sampleRoom(context)],
        ImageText: [
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
        ],
        bottomIndex: 0));
    data.add(onBoardingData(
        title: "Personal Expense",
        body:
            "Keep track of your personal expense month wise. You can also categorize your expenses so that you can analyze it later",
        widgets: [samplePE(context)],
        ImageText: [
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
        ],
        bottomIndex: 2));
    data.add(onBoardingData(
        title: "Len-Den",
        body:
            "Keep track of to whom you are lending money or borrow. You can invite that person to join so that ledger are in sync",
        widgets: [getSampleLD(context)],
        ImageText: [
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
        ],
        bottomIndex: 3));
    data.add(onBoardingData(
        title: "Analysis",
        body: "Analyze of personal expenses and room expenses using charts",
        widgets: [sampleRoomGraph(context), samplePEGraph(context)],
        ImageText: [
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
          'aiownfona fi aoi fioanfoianfoia of aoo oaifoiafoianofn aof a',
        ],
        bottomIndex: 4));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  MoveToDashBoard() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isOnBoardingCompleted", true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => DashBoard(
                version: widget.version,
              )),
      (Route<dynamic> route) => false,
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: pageIndex == index ? 25 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    data.clear();
    contextBuilder(context);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () {
                    MoveToDashBoard();
                  },
                  child: Text(
                    "Skip",
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.70,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: data.length,
                  onPageChanged: (index) {
                    if (this.mounted) {
                      setState(() {
                        pageIndex = index;
                      });
                    }
                  },
                  itemBuilder: (_, i) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          data[i].title,
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Text(
                          data[i].body,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24)),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2))),
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: data[i].widgets.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          data[i].widgets[index],
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            data[i].ImageText[index],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Expanded(
                                            child: SizedBox(),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                data[i].widgets.length,
                                                (indexDot) => Container(
                                                  height: 10,
                                                  width: indexDot == index
                                                      ? 25
                                                      : 10,
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 72,
                          decoration: BoxDecoration(
                              color: themeProvider.isDarkTheme
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : Colors.grey.shade50,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: BottomNavigationBar(
                                type: BottomNavigationBarType.fixed,
                                elevation: 0,
                                currentIndex: data[i].bottomIndex,
                                selectedIconTheme: IconThemeData(size: 40),
                                unselectedIconTheme: IconThemeData(size: 25),
                                items: [
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.home),
                                    label: "",
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.person_add_outlined),
                                    label: "",
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.wallet),
                                    label: "",
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.account_balance_outlined),
                                    label: "",
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.analytics_outlined),
                                    label: "",
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.person),
                                    label: "",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    data.length,
                    (index) => buildDot(index, context),
                  ),
                ),
              ),
              Container(
                  height: 60,
                  margin: EdgeInsets.all(40),
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 15.0,
                      ),
                      child: Text(
                        pageIndex == data.length - 1 ? "Get Started" : "Next",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.white),
                      ),
                      onPressed: () {
                        if (pageIndex == data.length - 1) {
                          MoveToDashBoard();
                        } else {
                          pageController.nextPage(
                            duration: Duration(milliseconds: 100),
                            curve: Curves.bounceIn,
                          );
                        }
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
