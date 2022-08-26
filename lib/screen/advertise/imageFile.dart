import 'package:flutter/material.dart';

class TemplateImages extends StatefulWidget {
  const TemplateImages({Key? key}) : super(key: key);

  @override
  _TemplateImagesState createState() => _TemplateImagesState();
}

class _TemplateImagesState extends State<TemplateImages> {
  List items=[
    'https://images.pexels.com/photos/9651396/pexels-photo-9651396.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
    'https://images.pexels.com/photos/9651396/pexels-photo-9651396.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
    'https://images.pexels.com/photos/9651396/pexels-photo-9651396.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: Icon(Icons.arrow_back_ios),
        title: Text('Post an Ad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: ClipRRect(
                borderRadius:BorderRadius.all(Radius.circular(8)),
                child: Image(
                    height: 180,
                    fit: BoxFit.cover,

                    image: NetworkImage(items[index],)
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

