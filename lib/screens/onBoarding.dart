import 'package:flutter/material.dart';

class onBoarding extends StatefulWidget {
  const onBoarding({Key? key}) : super(key: key);

  @override
  State<onBoarding> createState() => _onBoardingState();
}

class _onBoardingState extends State<onBoarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(),
        ),
      ),
    );
  }
}

class onBoardingContent extends StatefulWidget {
  /*
  title: "Personal Expense",
                body: "Here you can manage your person",
                ImagePath: [
                  'assets/onBoarding/2/light/sample_request_2.jpg',
                  'assets/onBoarding/2/light/sample_request2_2.jpg',
                  'assets/onBoarding/2/light/menu_bar_2.jpg'
                ],
                ImageText: [
                  'assets/onBoarding/2/light/sample_request_2.jpg',
                  'assets/onBoarding/2/light/sample_request2_2.jpg',
                  'assets/onBoarding/2/light/menu_bar_2.jpg'
                ],
                */
  final String title;
  final String body;
  final List<String> ImagePath;
  final List<String> ImageText;
  const onBoardingContent(
      {Key? key,
      required this.title,
      required this.body,
      required this.ImagePath,
      required this.ImageText})
      : super(key: key);

  @override
  State<onBoardingContent> createState() => _onBoardingContentState();
}

class _onBoardingContentState extends State<onBoardingContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                widget.title,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 35,
              ),
              Text(
                widget.body,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.ImagePath.length - 1,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  widget.ImagePath[index],
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.ImageText[index],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
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
              Image.asset(
                widget.ImagePath.last,
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
