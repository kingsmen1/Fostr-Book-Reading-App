import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fostr/widgets/AddBanner.dart';
import 'package:fostr/widgets/UserProfile/avatar.dart';

class PeekInPage extends StatefulWidget {
  const PeekInPage({Key? key}) : super(key: key);

  @override
  _PeekInPageState createState() => _PeekInPageState();
}

class _PeekInPageState extends State<PeekInPage> {
  static const blackStyle = TextStyle(color: Colors.black);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              "Rich Dad Poor Dad",
              style: blackStyle,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AdBanner(),
            const SizedBox(
              height: 16,
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 6,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150
                    ),
                    itemBuilder: (context, index) {
                      return UserAvatar(
                        name: "Name",
                        imageUrl: "",
                        radius: 50,
                      );
                    })),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      suffixIcon: Icon(Icons.send),
                      hintText: 'Express your thoughts',
                      contentPadding: const EdgeInsets.only(left: 20)),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SvgPicture.asset("assets/icons/blue_share.svg", width: 25, height: 25,),
                            // const Icon(
                            //   Icons.share,
                            //   size: 26,
                            // ),
                            Container(
                              padding: const EdgeInsets.all(0),
                              child: const Icon(
                                Icons.mic,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const Icon(
                              Icons.clear,
                              size: 26,
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -20,
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: const Icon(
                            Icons.mic,
                            size: 50,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
