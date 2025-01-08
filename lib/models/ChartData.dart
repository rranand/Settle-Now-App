class ChartData {
  String email = "";
  String name = "";
  String pic = "";
  String type = "";
  double amount = 0;

  ChartData.byType(String type, double amount) {
    this.type = type;
    this.amount = amount;
  }

  ChartData.byUser(String name, String email, String pic, double amount) {
    this.name = name;
    this.email = email;
    this.pic = pic;
    this.amount = amount;
  }

  ChartData.byRoom(String name, String type, double amount) {
    this.name = name;
    this.type = type;
    this.amount = amount;
  }
}

class ChartStackedLineData {
  String type = "";
  List<String> roomName = [];
  List<double> amount = [];

  ChartStackedLineData.byRoom(
      List<String> roomName, String type, List<double> amount) {
    this.roomName = roomName;
    this.type = type;
    this.amount = amount;
  }
}
