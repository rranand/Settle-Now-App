import 'package:flutter/material.dart';
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
            "Create your personalized room and invite your friends/family to join the room. Add expenses in the room and get the total expense split between members.",
        widgets: [sampleRoom(context)],
        ImageText: [
          'Open room by tapping button and see details of the room, like, members, room key, total expenditure, your spendings in the room, and other such information.',
        ],
        bottomIndex: 0));
    data.add(onBoardingData(
        title: "Personal Expense",
        body:
            "Track personal monthly expenses by adding expenses in different categories and analyze them later.",
        widgets: [samplePE(context)],
        ImageText: [
          'Image shows one of personal expense with its amount, category as Miscellaneous and creation date-time.'
        ],
        bottomIndex: 2));
    data.add(onBoardingData(
        title: "Len-Den",
        body:
            "Track lend/borrow money with single person in Len-Den category. Invite that person to join the room to keep both person in sync.",
        widgets: [getSampleLD(context)],
        ImageText: [
          'You can check how much money you gave/borrowed from your friend.',
        ],
        bottomIndex: 3));
    data.add(onBoardingData(
        title: "Analysis",
        body:
            "Attractive graphs to help you analyze room expenses and personal expenses.",
        widgets: [sampleRoomGraph(context), samplePEGraph(context)],
        ImageText: [
          'Analyze each month total expense with the help of bar chart.',
          'Analyze each year total expense with the help of line chart.',
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
                                    color: data[i].widgets.length == 1
                                        ? Theme.of(context)
                                            .scaffoldBackgroundColor
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2))),
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: data[i].widgets.length == 1
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                            height: 165,
                                            child: data[i].widgets[0]),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data[i].widgets.length,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.95,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              data[i].widgets[index],
                                              /*SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                data[i].ImageText[index],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),*/
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
                                                      margin: EdgeInsets.only(
                                                          right: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
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
                        Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: BottomNavigationBar(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
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
