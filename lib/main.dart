import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text("Scrape Information from PDF"),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => _extractText(context),
                      child: const Text(
                        'Generate PDF',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            )
        )
    );
  }

  Future<void> _extractText(BuildContext context, [bool mounted = true]) async {
    //Load an existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('assets/ementas_engenharia.pdf'));
    if (!mounted) return;
    Navigator.pop(context);

    //Create a new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);
    Rect titleBounds = const Rect.fromLTWH(0, 100, 1000, 40);
    Rect mealsBounds = const Rect.fromLTRB(0, 130, 390, 750);
    List<String> headers = [];
    List<String> weeklyMeals = [];
    for (int pageNr = 2; pageNr < 3; pageNr++) {
      //Extract lines from one page
      List<TextLine> lines = extractor.extractTextLines(
          startPageIndex: pageNr, endPageIndex: pageNr);

      String header = "";
      for (int i = 0; i < lines.length; i++) {
        List<TextWord> wordCollection = lines[i].wordCollection;
        for (int j = 0; j < wordCollection.length; j++) {
          if (titleBounds.overlaps(wordCollection[j].bounds)) {
            header += '#${wordCollection[j].text}';
          }
        }
        if (header != '') {
          break;
        }
      }

      headers.add(header);

      String meals = '';
      for (int i = 0; i < lines.length; i++) {
        List<TextWord> wordCollection = lines[i].wordCollection;
        for (int j = 0; j < wordCollection.length; j++) {
          if (mealsBounds.overlaps(wordCollection[j].bounds)) {
            meals += '#${wordCollection[j].text}';
          }
        }
      }

      weeklyMeals.add(meals);
    }

    //Display the text.
    var i = 0;
    _showResult(context, weeklyMeals.join('--\n'));
    print(weeklyMeals.join());
  }

  void _showResult(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Extracted text'),
            content: Scrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Text(text),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<Uint8List> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load(name);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
