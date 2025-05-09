import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class GeminiService {
  final String apiKey = 'AIzaSyA1TmyLwnan8pPh5aaQI0ucTqYzZARn91c';

  late GenerativeModel model;
  late ChatSession chat;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 1024,
        responseMimeType: 'text/plain',
      ),
    );
    chat = model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    final content = Content.text(message);
    final response = await chat.sendMessage(content);
    return response.text;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PDFQuestionGenerator(),
    );
  }
}

class PDFQuestionGenerator extends StatefulWidget {
  const PDFQuestionGenerator({super.key});

  @override
  _PDFQuestionGeneratorState createState() => _PDFQuestionGeneratorState();
}

class _PDFQuestionGeneratorState extends State<PDFQuestionGenerator> {
  final GeminiService gemini = GeminiService();
  List<Map<String, String>> questionsAndAnswers = [];
  TextEditingController textController = TextEditingController();

  Future<void> pickAndExtractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      print("Selected file path: $filePath");
      File file = File(filePath);

      try {
        final PdfDocument pdfDoc = PdfDocument(
          inputBytes: file.readAsBytesSync(),
        );
        String text = "";
        for (int i = 0; i < pdfDoc.pages.count; i++) {
          PdfTextExtractor extractor = PdfTextExtractor(pdfDoc);
          text += "${extractor.extractText()}\n\n";
        }

        print("Extracted text: $text");
        print("Is extracted text empty: ${text.isEmpty}");

        pdfDoc.dispose();

        generateQuestionsFromText(text);
      } catch (e) {
        setState(() {});
      }
    } else {
      setState(() {});
    }
  }

  Future<void> generateQuestionsFromText(String text) async {
    String prompt =
        "Generate questions and answers, keep the answer short for example(1 to 3 words only) from the following text. Format it as a valid Dart list of maps like this: [{ \"question\": \"...\", \"answer\": \"...\" }, ...]. Text: $text";

    String? response = await gemini.sendMessage(prompt);

    print("Raw Response: $response"); // Debugging response from Gemini

    if (response != null) {
      try {
        // Attempt to clean response if it includes markdown/code block formatting
        response = response.trim();
        if (response.startsWith("```json")) {
          response =
              response.replaceAll("```json", "").replaceAll("```", "").trim();
        }
        if (response.startsWith("```dart")) {
          response =
              response.replaceAll("```dart", "").replaceAll("```", "").trim();
        }

        print("Cleaned Response: $response"); // Check cleaned response

        // Attempt to parse as a Dart list of maps
        var decodedData = jsonDecode(response);

        if (decodedData is List) {
          setState(() {
            questionsAndAnswers = List<Map<String, String>>.from(
              decodedData.map((item) => Map<String, String>.from(item)),
            );
          });

          print(
            "Parsed Questions: $questionsAndAnswers",
          ); // Debugging parsed questions
        } else {
          throw Exception("Response is not a List format.");
        }
      } catch (e) {
        print("Parsing Error: $e"); // Debugging error
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF to Questions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: pickAndExtractText,
              child: Text("Pick PDF"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Or paste your text here",
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                generateQuestionsFromText(textController.text);
              },
              child: Text("Generate Questions from Text"),
            ),
            SizedBox(height: 16),
            Text(
              "Extracted Questions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: questionsAndAnswers.isNotEmpty
                  ? ListView.builder(
                      itemCount: questionsAndAnswers.length,
                      itemBuilder: (context, index) {
                        final qa = questionsAndAnswers[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Q: ${qa['question']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "A: ${qa['answer']}",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Text("No questions generated."),
            ),
          ],
        ),
      ),
    );
  }
}
