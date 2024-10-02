import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class SajuNaming extends StatefulWidget {
  const SajuNaming({super.key, required this.title});

  final String title;

  @override
  State<SajuNaming> createState() => _SajuNamingState();
}

class _SajuNamingState extends State<SajuNaming> with SingleTickerProviderStateMixin{
  TextEditingController urlController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController monthController = TextEditingController();
  TextEditingController dayController = TextEditingController();

  String userGender = '남자';
  final List<bool> _toggleGender = [true, false];

  List<String> name = [];
  List<String> wname = [];

  late String year;
  late String month;
  late String day;
  late String prompt;
  late String explain;
  late String selectedName;
  late String nameMean;

  late AnimationController _controller;
  late Animation<int> _animation;

  bool isLoading = false;
  bool isReadyModel = true;
  bool isEnd = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this)..repeat(reverse: true);

    // 0부터 3까지의 정수 애니메이션 생성
    _animation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            height: 500,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isEnd ? endPage() : isReadyModel ? readyModel() : nonReadyModel()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nonReadyModel() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              String dots = '.' * _animation.value;
              return Text('시스템 준비 중$dots', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),);
            },
          ),
          const SizedBox(height: 40,),
          SizedBox(
            width: 350,
            child: TextFormField(
              textAlign: TextAlign.center,
              cursorColor: Colors.black,
              enabled: true,
              decoration: const InputDecoration(
                hintText: '서버 url을 입력하시오',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black,
                      width: 2
                  ),
                ),
                isDense: true,
              ),
              controller: urlController,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(height: 20,),
          IconButton(onPressed: () async {
            final url = Uri.parse('${urlController.text}/check');
            try {
              var response = await http.get(url,
                  headers: {
                    'ngrok-skip-browser-warning': 'yes'
                  });
              var responseData = jsonDecode(response.body);
              setState(() {
                isReadyModel = responseData['isReady'];
              });
            } catch (e, s) {
              print("Error: $e");
              print("trace: $s");
              urlController.text = '';
            }
          }, icon: const Icon(Icons.refresh, size: 40,))
        ]
    );
  }

  Widget readyModel() {
    return isLoading ? loadingPage('이름 추천 중') : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        birthdayInputField(),
        const SizedBox(height: 40,),
        genderToggle(),
        const SizedBox(height: 60,),
        submitBtn()
      ],
    );
  }

  Widget endPage() {
    return isLoading ? loadingPage('최종 결과 기다리는 중') : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${yearController.text}/${monthController.text}/${dayController.text}', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(year, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
            const SizedBox(width: 10,),
            Text(month, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
            const SizedBox(width: 10,),
            Text(day, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
          ],
        ),
        Text('$prompt 이 사주는 $explain 이를 이용해 아래의 $userGender 이름을 추천합니다.', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
        const SizedBox(height: 20,),
        Text(selectedName, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
        const SizedBox(height: 20,),
        Text('이 이름은 $nameMean 의 뜻을 가집니다', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center,),
        const SizedBox(height: 30,),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(250, 50)
          ),
          child: const Text("처음으로 돌아가기", style: TextStyle(fontSize: 20, color: Colors.black,)),
          onPressed: () {
            setState(() {
              isEnd = false;
              yearController.text = '';
              monthController.text = '';
              dayController.text = '';
            });
          },
        ),
      ],
    );
  }

  Widget birthdayInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('생년월일', style: TextStyle(fontSize: 16, color: Colors.black)),
        const SizedBox(height: 30,),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                cursorColor: Colors.black,
                inputFormatters: [
                  FilteringTextInputFormatter(
                    RegExp(r'[0-9]'),
                    allow: true,
                  ),
                  LengthLimitingTextInputFormatter(4)
                ],
                enabled: true,
                decoration: const InputDecoration(
                  hintText: '생년',
                  helperText: '',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black,
                        width: 2
                    ),
                  ),
                  isDense: true,
                ),
                controller: yearController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Expanded(child: Center(child: Text(' / ', style: TextStyle(fontSize: 24, color: Colors.black)))),
            Expanded(
              flex: 2,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                cursorColor: Colors.black,
                inputFormatters: [
                  FilteringTextInputFormatter(
                    RegExp(r'[0-9]'),
                    allow: true,
                  ),
                  LengthLimitingTextInputFormatter(2)
                ],
                enabled: true,
                decoration: const InputDecoration(
                  hintText: '월',
                  helperText: '',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black,
                        width: 2
                    ),
                  ),
                  isDense: true,
                ),
                controller: monthController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Expanded(child: Center(child: Text(' / ', style: TextStyle(fontSize: 24, color: Colors.black)))),
            Expanded(
              flex: 2,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                cursorColor: Colors.black,
                inputFormatters: [
                  FilteringTextInputFormatter(
                    RegExp(r'[0-9]'),
                    allow: true,
                  ),
                  LengthLimitingTextInputFormatter(2)
                ],
                enabled: true,
                decoration: const InputDecoration(
                  hintText: '일',
                  helperText: '',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black,
                        width: 2
                    ),
                  ),
                  isDense: true,
                ),
                controller: dayController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget genderToggle() {
    return ToggleButtons(
      selectedBorderColor: Colors.black,
      borderRadius: BorderRadius.circular(10),
      isSelected: _toggleGender,
      onPressed: (index) {
        setState(() {
          if (index == 0) {
            _toggleGender[0] = true;
            _toggleGender[1] = false;
            userGender = '남자';
          }
          else {
            _toggleGender[0] = false;
            _toggleGender[1] = true;
            userGender = '여자';
          }
        }
        );
      },
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          child: Text("남자", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.0),
          child: Text("여자", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ],
    );
  }

  Widget submitBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(onPressed: () async {
          setState(() {
            isLoading = true;
          });

          final url = Uri.parse('${urlController.text}/name');

          try {
            var response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'ngrok-skip-browser-warning': 'yes'
              },
              body: jsonEncode({
                'year': yearController.text,
                'month': monthController.text,
                'day': dayController.text,
                'gender': userGender
              })
            );

            var responseData = jsonDecode(response.body);
            prompt = responseData['prompt'];
            explain = responseData['explain'];
            year = responseData['year'] + '년';
            month = responseData['month'] + '월';
            day = responseData['day'] + '일';
            name.add(responseData['name1']);
            name.add(responseData['name2']);
            name.add(responseData['name3']);
            wname.add(responseData['wname1']);
            wname.add(responseData['wname2']);
            wname.add(responseData['wname3']);

            isLoading = false;
            showNameDialog();

          } catch (e, s) {
            print("Error: $e");
            print("trace: $s");
          }

        },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50)
            ),
            child: const Text('추천받기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
      ],
    );
  }

  Widget loadingPage(String str) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            String dots = '.' * _animation.value;
            return Text('$str$dots', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),);
          },
        ),
        const SizedBox(height: 20,),
        const SizedBox(
          width: 250,
          height: 250,
          child: SpinKitFadingCircle(
            color: Colors.deepPurpleAccent,
          ),
        )
      ],
    );
  }

  void showNameDialog() {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Column(
              children: [
                Text('추천하는 이름입니다\n원하시는 이름을 선택해주세요', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
              ],
            ),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chooseName(context, 0),
                  chooseName(context, 1),
                  chooseName(context, 2)
                ],
              ),
            ),
          );
        });
  }

  Widget chooseName(BuildContext context, int index) {
    return Container(
        width: 150,
        height: 150,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(150, 150)
          ),
          child: Text(wname[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center,),
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isLoading = true;
              isEnd = true;
            });

            final url = Uri.parse('${urlController.text}/mean');

            try {
              var response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    'ngrok-skip-browser-warning': 'yes'
                  },
                  body: jsonEncode({
                    'name': name[index],
                  })
              );

              var responseData = jsonDecode(response.body);
              selectedName = wname[index];
              nameMean = responseData['mean'];

              setState(() {
                isLoading = false;
              });

            } catch (e, s) {
              print("Error: $e");
              print("trace: $s");
            }
          },
        )
    );
  }
}
