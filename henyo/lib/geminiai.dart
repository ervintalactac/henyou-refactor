import 'package:flutter/material.dart';
import 'package:gemini_flutter/gemini_flutter.dart';

// import 'image.dart';

void main() {
  // GeminiHandler().initialize(apiKey: "AIzaSyDm1nuvYyXEyJYzmvKZsxy5Py1OEr7gMUw");
  // GeminiHandler().initialize(apiKey: "AIzaSyBAUSNsq1TawYWQcILpNEq7vXHe48Rg6QY");
  GeminiHandler().initialize(apiKey: "AIzaSyAoYR-pL5Ve2_j2aWHuarZ6--eurjoeRyw");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String textData = "";
//   String prompt =
//       """You're an english and tagalog dictionary and wikipedia expert and I’ll give you two words separated by colon(:) like 'subject1:subject2'
// and you'll tell me if subject2 directly describes, belongs, part of or equates to subject1 by answering yes.
// If subject2 is not typically subject1 but somewhat like it or relates to it then answer close.
// If none of the above fits the criteria then answer no.
// Response should only be one of the three, 'yes', 'close' or 'no'.
// Words to be compared will be in english and/or tagalog. NO EXPLANATION NEEDED! """;
  String prompt = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gemini Demo"),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      final response = await GeminiHandler().geminiPro(
                          text:
                              'mga hayop sa pilipinas na nagsisimula sa letrang m');
                      textData = response
                              ?.candidates?.first.content?.parts?.first.text ??
                          "Failed to fetch data";
                      setState(() {});
                    },
                    child: const Text("Gemini Pro")),
                // ElevatedButton(
                //     onPressed: () async {
                //       final response = await GeminiHandler().geminiProVision(
                //           logCountTokens: true,
                //           base64Format: imageBase64,
                //           text: "I am blind can you describe me the image");
                //       textData = response
                //               ?.candidates?.first.content?.parts?.first.text ??
                //           "Failed to fetch data";
                //       setState(() {});
                //     },
                //     child: const Text("Gemini Pro Vision")),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Press the button to get the response from Gemini',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            const Text(
              'Tokens Used: ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              textData,
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
