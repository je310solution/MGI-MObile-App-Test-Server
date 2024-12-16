import 'package:flutter/material.dart';
import 'package:mapa_bea/widgets/shimmering_loader.dart';

class DataLoader extends StatefulWidget {
  @override
  State<DataLoader> createState() => _DataLoaderState();
}

class _DataLoaderState extends State<DataLoader> {
  final ShimmeringLoader _shimmeringLoader = new ShimmeringLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(int x = 0; x < 2; x++)...{
            _shimmeringLoader.pageLoader(radius: 5, width: 330, height: 25),
            SizedBox(
              height: 20,
            ),
            _shimmeringLoader.pageLoader(radius: 5, width: 250, height: 20),
            SizedBox(
              height: 10,
            ),
            _shimmeringLoader.pageLoader(radius: 5, width: 200, height: 15),
            SizedBox(
              height: 20,
            ),
            _shimmeringLoader.pageLoader(radius: 5, width: 250, height: 20),
            SizedBox(
              height: 10,
            ),
            _shimmeringLoader.pageLoader(radius: 5, width: 200, height: 15),
            SizedBox(
              height: 20,
            ),
            _shimmeringLoader.pageLoader(radius: 5, width: 250, height: 20),
            SizedBox(
              height: 10,
            ),
            _shimmeringLoader.pageLoader(radius: 5, width: 200, height: 15),
            SizedBox(
              height: 20,
            ),
            _shimmeringLoader.pageLoader(radius: 1000, width: double.infinity, height: 35),
            SizedBox(
              height: 10,
            ),
            x == 0 ? Divider() : Container(),
            SizedBox(
              height: 10,
            ),
          }
        ],
      ),
    );
  }
}
