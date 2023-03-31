import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
//import 'package:model_viewer_plus/model_viewer_plus.dart';
//import 'package:simple_permissions/simple_permissions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImageWidget(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => MyHomePage()));
        },
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 3,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 2,
            crossAxisCount: 1,
          ),
          itemBuilder: (context, index) {
            return Card(
              elevation: 20,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
              child: Image.asset(
                'assets/beadsblend.png',
                width: 400,
                height: 200,
                semanticLabel: "first design",
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  static int numRows = 11;
  static int numColumns = 50;
  static int totalCells = numRows * numColumns;
  var selectedIndex = 0;
  // Create a list to hold the colors of each cell

  List<Color> _colors = List.generate(totalCells, (index) => Colors.red);
  //final String jsonString =  rootBundle.loadString('./colors.json') as String;

  // Create a variable to hold the selected color
  Color _selectedColor = Colors.black;
  List<Color> _colorsCopy = List.generate(totalCells, (index) => Colors.grey);
  int _highlightedColumnIndex = -1;

  void _load_json() async {
    final jsonString = await rootBundle.loadString('assets/colors.json');
    List<Color> colors = (jsonDecode(jsonString) as List<dynamic>)
        .map((color) => Color(color))
        .toList();
    setState(() {
      _colors = List<Color>.from(colors);
      _colorsCopy = List<Color>.from(colors);
      _highlightedColumnIndex = -1;
    });
  }

  // write a function to modify the _highlightNextColumn() method to highlight the columns in reverse
  void _highlightNextColumn(String direction) {
    setState(() {
      if (direction == "reset") {
        _highlightedColumnIndex = -1;
        for (int i = 0; i < totalCells; i++) {
          _colors[i] = _colorsCopy[i];
          direction = "forward";
        }
      }
      // Un-highlight the previous column, if there was one
      if (_highlightedColumnIndex == -1) {
        for (int i = 0; i < totalCells; i++) {
          _colors[i] = _colorsCopy[i].withOpacity(0.1);
        }
      }
      if (_highlightedColumnIndex >= 0) {
        for (int i = 0; i < numRows; i++) {
          _colors[_highlightedColumnIndex + i * numColumns] =
              _colorsCopy[_highlightedColumnIndex + i * numColumns]
                  .withOpacity(0.1);
        }
      }
      if (direction == 'forward') {
        // Highlight the next column, or start from the beginning if we've reached the end
        _highlightedColumnIndex = (_highlightedColumnIndex + 1) % numColumns;
        for (int i = 0; i < numRows; i++) {
          _colors[_highlightedColumnIndex + i * numColumns] =
              _colorsCopy[_highlightedColumnIndex + i * numColumns];
        }
      } else if (direction == 'backward') {
        // Highlight the next column, or start from the beginning if we've reached the end
        _highlightedColumnIndex = (_highlightedColumnIndex - 1) % numColumns;
        for (int i = 0; i < numRows; i++) {
          _colors[_highlightedColumnIndex + i * numColumns] =
              _colorsCopy[_highlightedColumnIndex + i * numColumns];
        }
      }
    });
  }
//

// write a function that saves the _colors list as a .json file
//
// write a function that loads the .json file and sets the _colors list to the loaded data
  void saveColorsToJson(List<Color> colors) async {
    //final directory = await getApplicationDocumentsDirectory();
    final file = File('./colors.json');
    final colorsJson = jsonEncode(colors.map((color) => color.value).toList());
    await file.writeAsString(colorsJson);
  }

  @override
  Widget build(BuildContext context) {
    Random random = Random();
    return Scaffold(
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.infinity),
        scaleEnabled: true,
        minScale: 0.01,
        maxScale: 10.0,
        child: Scaffold(
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(100.0),
              width: 400,
              height: 1000,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: numRows * numColumns,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  crossAxisCount: numColumns,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // On tap, change the color of the cell to the selected color
                      setState(() {
                        _colors[index] = _selectedColor;
                        _colorsCopy[index] = _selectedColor;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _colors[index],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ]),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'highlight2',
        child: Text('Down'),
        onPressed: () {
          _highlightNextColumn("forward");
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.grey[300],
          child: Wrap(
            children: [
              _buildColorOption(Colors.black),
              _buildColorOption(Colors.red),
              _buildColorOption(Colors.green),
              _buildColorOption(Colors.blue),
              _buildColorOption(Colors.yellow),
              FloatingActionButton(
                heroTag: 'highlight',
                child: Text('Down'),
                onPressed: () {
                  _highlightNextColumn("forward");
                },
              ),
              FloatingActionButton(
                hoverColor: Color.fromARGB(255, random.nextInt(256),
                    random.nextInt(256), random.nextInt(256)),
                //backgroundColor: Colors.black,
                heroTag: 'highlightBack',
                child: Text('Up1'),
                onPressed: () {
                  _highlightNextColumn("backward");
                },
              ),
              FloatingActionButton(
                heroTag: 'resetColors',
                child: Text('reset'),
                onPressed: () {
                  _highlightNextColumn("reset");
                },
              ),
              Visibility(
                visible: false,
                child: FloatingActionButton(
                  heroTag: 'saveColors',
                  child: Text('save colors'),
                  onPressed: () {
                    saveColorsToJson(_colors);
                  },
                ),
              ),
              FloatingActionButton(
                heroTag: 'loadDesign',
                child: Text('show'),
                onPressed: () {
                  _load_json();
                },
              ),
              Visibility(
                visible: false,
                child: FloatingActionButton(
                  heroTag: 'generate',
                  child: Text('Generate Grid'),
                  onPressed: () {
                    generateAndSaveGrid(_colors);
                    print('Grid Generated');
                  },
                ),
              ),
              Visibility(
                visible: false,
                child: FloatingActionButton(
                  heroTag: '3d',
                  child: Text('3D'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        // On tap, update the selected color
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        width: 50,
        height: 50,
        color: color,
      ),
    );
  }
}

void generateAndSaveGrid(List colors) async {
  // Define the size of the grid and the size of each square
  final gridSize = Size(11 * 100.0, 50 * 100.0);
  final squareSize = 100.0;

  // Create a PictureRecorder to record the painting
  PictureRecorder recorder = PictureRecorder();
  Canvas canvas = Canvas(recorder);

  // Paint each square with a random color
  Random random = Random();
  var index = 0;
  for (int i = 0; i < 11; i++) {
    for (int j = 0; j < 50; j++) {
      Paint paint = Paint()..color = colors[index]; //.fromARGB(
      //255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
      index++;
      canvas.drawRect(
          Rect.fromLTWH(i * squareSize, j * squareSize, squareSize, squareSize),
          paint);
    }
  }

  // Create a picture from the recorded painting
  Picture picture = recorder.endRecording();

  // Convert the picture to an image
  ui.Image image =
      await picture.toImage(gridSize.width.floor(), gridSize.height.floor());

  // Convert the image to a ByteData object
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  // Write the ByteData object to a file on disk
  final file = File('beadsblend.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List());
}
