import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/notification.dart';
import 'package:instagram/style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

/* 동적 UI 만들기
1. 위젯을 StatefulWidget으로 생성한다.
2. state에 현재 UI의 상태를 저장한다.
3. setState로 상태가 변화하도록 한다. */

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (create) => Store()),
        ChangeNotifierProvider(create: (create) => Store2()),
      ],
      child: MaterialApp(
        theme: style.theme,
        initialRoute: "/",
        routes: {
          "/": (context) => MyApp(),
          "/upload": (context) => Upload(),
        },
      ),
    )
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final listItem = [CustomListItem(), CustomListItem()];

  var tap = 0;
  var result = [];
  var userImage;
  var userContent;

  void getData() async {
    // TODO : Dio 패키지 함께 사용해보기
    var request = await http.get(Uri.parse("https://codingapple1.github.io/app/data.json"));
    if (request.statusCode == 200) {
      setState(() {
        result = jsonDecode(request.body);
      });
    } else {
      print("request failed");
    }
  }

  void addData(a) {
    setState(() {
      result.add(a);
    });
  }

  void setUserContent(content) {
    setState(() {
      userContent = content;
    });
  }

  void addMyData() {
    var myData = {
      "id": result.length,
      "image": userImage,
      "likes": 5,
      "date": "July 25",
      "content": userContent,
      "liked": false,
      "user": "John Kim"
    };
    setState(() {
      result.insert(0, myData);
    });
  }

  void saveData() async {
    var storage = await SharedPreferences.getInstance();
    storage.setString("key", "value");
    print(storage.getString("key"));
  }
  
  @override
  void initState() {
    super.initState();
    initNotification();
    // initNotification(context);
    getData();
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text("+"),
        onPressed: () {
          showNotification();
        },
      ),
      appBar: AppBar(
        centerTitle: false,
        title: Text("Instagram"),
        actions: [
          IconButton(
            onPressed: () async {
              var imagePicker = ImagePicker();
              var image = await imagePicker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }

              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Upload(
                  userImage: userImage,
                  setUserContent: setUserContent,
                  addMyData: addMyData,
                ))
              );
            },
            icon: Icon(Icons.add_box_outlined),
            iconSize: 30,
          )
        ],
      ),
      body: [CustomListView(result: result, addData: addData), Text("shop")][tap],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (idx) {
          setState(() {
            tap = idx;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "샵"),
        ],
      )
    );
  }
}

class CustomListView extends StatefulWidget {
  const CustomListView({Key? key, this.result, this.addData}) : super(key: key);
  final result;
  final addData;

  @override
  State<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {

  var scroll = ScrollController();
  var data = [];

  void getMoreData() async {
    var request = await http.get(Uri.parse("https://codingapple1.github.io/app/more1.json"));
    var moreData = jsonDecode(request.body);
    widget.addData(moreData);
  }

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result.isNotEmpty) {
      return ListView.builder(itemCount: widget.result.length, controller: scroll, itemBuilder: (c, i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.result[i]["image"].runtimeType == String
                ? Image.network(widget.result[i]["image"])
                : Image.file(widget.result[i]["image"]),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Text(widget.result[i]["user"]),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (c) => Profile())
                      );
                    },
                  ),
                  Text("좋아요 ${widget.result[i]["likes"]}", style: TextStyle(fontWeight: FontWeight.w700)),
                  Text("${widget.result[i]["date"]}"),
                  Text("${widget.result[i]["content"]}"),
                ],
              ),
            )
          ],
        );
      });
    } else {
      return Text("loading...");
    }
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage, this.setUserContent, this.addMyData}) : super(key: key);
  final userImage;
  final setUserContent;
  final addMyData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: () {
              addMyData();
              Navigator.pop(context);
            },
            icon: Icon(Icons.send)
          )],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(userImage),
          TextField(onChanged: (text) {
            setUserContent(text);
          }),
          Text("data"),
        ],
      ),
    );
  }
}

class Store extends ChangeNotifier {
  var follower = 0;
  var buttonPush = false;
  var profileImage = [];

  void addFollower() {
    if (buttonPush == false) {
      follower++;
      buttonPush = true;
    } else {
      follower--;
      buttonPush = false;
    }
    notifyListeners();
  }

  void getData() async {
    var data = await http.get(Uri.parse("https://codingapple1.github.io/app/profile.json"));
    var result = jsonDecode(data.body);
    profileImage.add(result);
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier {
  var name = "John Kim";
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<Store2>().name),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader()
          ),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                  (c, i) => Image.network(context.watch<Store>().profileImage[i][i]),
                childCount: context.watch<Store>().profileImage.length
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3)
          )
        ],
      )
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey,
        ),
        Text("팔로워 ${context.watch<Store>().follower}명"),
        ElevatedButton(
            onPressed: () {
              context.read<Store>().addFollower();
            },
            child: Text("팔로우")
        ),
        ElevatedButton(onPressed: () {
          context.read<Store>().getData();
        }, child: Text("사진가져와"))
      ],
    );
  }
}
