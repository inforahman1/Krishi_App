import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const green = Color(0xFF006A4E);
const darkGreen = Color(0xFF1B5E20);
const red = Color(0xFFC62828);
const phone = '01826106110';
final bn = ValueNotifier<bool>(true);
String t(String s) => s.split('|')[bn.value ? 0 : 1];

class Sec {
  final String name, feed, disease, care;
  final IconData icon;
  final bool plant;
  const Sec(this.name, this.icon, this.feed, this.disease, this.care, {this.plant = false});
}

const secs = <Sec>[
  Sec('গাছ|Plants', Icons.local_florist,
      'ইউরিয়া, টিএসপি ও এমওপি সার মাটি পরীক্ষা অনুযায়ী কিস্তিতে দিন; কম্পোস্ট ও গোবর সার মাটির স্বাস্থ্য বাড়ায়।|Apply urea, TSP and MoP in split doses as per soil test; compost and cow dung improve soil health.',
      'পাতায় দাগ, ঢলে পড়া বা পোকা দেখলে আক্রান্ত অংশ সরান এবং কৃষি কর্মকর্তার পরামর্শে অনুমোদিত ছত্রাকনাশক/কীটনাশক ব্যবহার করুন।|For leaf spots, wilting or pests, remove affected parts and use approved fungicide/pesticide on advice of an agriculture officer.',
      'ভালো বীজ বা চারা বাছুন, পর্যাপ্ত আলো ও সেচ দিন, আগাছা পরিষ্কার রাখুন।|Choose good seed or saplings, ensure sunlight and irrigation, keep weeds cleared.',
      plant: true),
  Sec('শাকসবজি|Vegetables', Icons.eco,
      'জৈব সারের সাথে ইউরিয়া, টিএসপি ও এমওপি পরিমিত দিন; ফল ধরার সময় পটাশ বাড়ান।|Use organic manure with measured urea, TSP and MoP; increase potash at fruiting.',
      'মড়ক, পাতা কুঁকড়ানো ও ফল ছিদ্রকারী পোকা সাধারণ; আক্রান্ত গাছ তুলে ফেলুন ও কৃষি কর্মকর্তার পরামর্শ নিন।|Blight, leaf curl and fruit borers are common; uproot infected plants and consult an agriculture officer.',
      'উঁচু বেড, নিয়মিত সেচ ও পানি নিষ্কাশন, ফসল পর্যায়ক্রমে চাষ করুন।|Raised beds, regular irrigation and drainage, rotate crops.',
      plant: true),
  Sec('হাঁস|Duck', Icons.water,
      'ক্ষুদ, শামুক-ঝিনুক, ভাত, সবুজ পাতা ও সুষম দানাদার খাবার; পরিষ্কার পানি দিন।|Broken rice, snails, greens and balanced pellets; always provide clean water.',
      'হাঁসের প্লেগ ও কলেরা প্রধান; সময়মতো টিকা দিন, অসুস্থ হাঁস আলাদা করুন, ভেটেরিনারি ডাক্তার দেখান।|Duck plague and cholera are common; vaccinate on time, isolate sick ducks, see a vet.',
      'শুকনো ও নিরাপদ ঘর, চরার সুযোগ, নিয়মিত কৃমিনাশক।|Dry safe shed, access to forage, regular deworming.'),
  Sec('মুরগি|Chicken', Icons.egg,
      'ভুট্টা, চালের কুঁড়া, সয়াবিন মিল ও ক্যালসিয়ামসহ সুষম খাবার; বয়স অনুযায়ী স্টার্টার, গ্রোয়ার ও লেয়ার খাবার।|Balanced feed of maize, rice bran, soybean meal and calcium; starter, grower and layer feed by age.',
      'রানীক্ষেত, গামবোরো, ককসিডিওসিস ও বার্ড ফ্লু ঝুঁকিপূর্ণ; টিকা সূচি মানুন, অসুস্থ মুরগি আলাদা করে ডাক্তারকে জানান।|Newcastle, Gumboro, coccidiosis and bird flu are risks; follow the vaccination schedule, isolate sick birds and call a vet.',
      'পরিষ্কার ও বাতাসযুক্ত ঘর, লিটার শুকনো রাখুন, অপরিচিত পাখি ঢুকতে দেবেন না।|Clean ventilated house, keep litter dry, keep out strange birds.'),
  Sec('গরু|Cow', Icons.pets,
      'কাঁচা ঘাস, খড়, ভুসি, খৈল ও দানাদার মিশ্রণ; খনিজ লবণ ও পরিষ্কার পানি।|Green fodder, straw, bran, oilcake and concentrate mix; mineral salt and clean water.',
      'খুরা রোগ, তড়কা, ওলান প্রদাহ ও পেট ফাঁপা দেখা দেয়; নিয়মিত টিকা ও কৃমিনাশক দিন, লক্ষণ দেখলে দ্রুত ডাক্তার ডাকুন।|Foot-and-mouth, anthrax, mastitis and bloat occur; vaccinate and deworm regularly, call a vet quickly on symptoms.',
      'শুকনো উঁচু গোয়াল, নিয়মিত পরিষ্কার-পরিচ্ছন্নতা, দোহনের আগে ওলান ধোয়া।|Dry raised shed, regular cleaning, wash udder before milking.'),
  Sec('ছাগল|Goat', Icons.pets,
      'কাঁঠাল ও ইপিল-ইপিল পাতা, কাঁচা ঘাস, ভুসি ও দানা; লবণ ও পানি।|Jackfruit and ipil-ipil leaves, grass, bran and grain; salt and water.',
      'পিপিআর, কৃমি, নিউমোনিয়া ও ডায়রিয়া সাধারণ; পিপিআর টিকা ও কৃমিনাশক দিন, অসুস্থ ছাগল আলাদা রাখুন।|PPR, worms, pneumonia and diarrhoea are common; give PPR vaccine and dewormer, isolate sick goats.',
      'মাচা ঘর, বৃষ্টি ও ঠান্ডা থেকে সুরক্ষা, নিয়মিত খুর পরিষ্কার।|Raised slatted shed, protection from rain and cold, regular hoof care.'),
  Sec('মাছ|Fish', Icons.set_meal,
      'প্রজাতি ও আকার অনুযায়ী ভাসমান বা ডুবন্ত সুষম পেলেট, দিনে ২-৩ বার।|Floating or sinking balanced pellets by species and size, 2-3 times daily.',
      'ক্ষত রোগ, ফুলকা পচা ও সাদা দাগ রোগ হয়; পুকুরে চুন দিন, পানির মান ঠিক রাখুন, মৎস্য কর্মকর্তার পরামর্শ নিন।|Ulcer disease, gill rot and white spot occur; apply lime, keep water quality good, consult a fisheries officer.',
      'পুকুর শুকিয়ে চুন দিন, সঠিক ঘনত্বে পোনা ছাড়ুন, অক্সিজেন ও পিএইচ পরীক্ষা করুন।|Dry and lime the pond, stock at the right density, check oxygen and pH.'),
];

void main() => runApp(const KrishiApp());

class KrishiApp extends StatelessWidget {
  const KrishiApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
        title: 'কৃষি',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: green),
          scaffoldBackgroundColor: const Color(0xFFE8F5E9),
        ),
        home: const Home(),
      );
}

Widget langBtn() => TextButton(
      onPressed: () => bn.value = !bn.value,
      child: Text(bn.value ? 'EN' : 'বাংলা', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext c) => ValueListenableBuilder<bool>(
        valueListenable: bn,
        builder: (c, _, __) => Scaffold(
          appBar: AppBar(
            backgroundColor: green,
            title: const Text('কৃষি', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              langBtn(),
              IconButton(icon: const Icon(Icons.key, color: Colors.white), onPressed: () => keyDialog(c)),
              IconButton(icon: const Icon(Icons.feedback, color: Colors.white), onPressed: () => feedbackDialog(c)),
            ],
          ),
          body: Column(children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(12),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [for (final s in secs) secCard(c, s)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                t('ডেভেলপড বাই আব্দুর রহমান\nQynvaro Technology\nফোন: $phone|Developed by Abdur Rahman\nQynvaro Technology\nPhone: $phone'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: darkGreen, fontSize: 12),
              ),
            ),
          ]),
        ),
      );
}

Widget secCard(BuildContext c, Sec s) => InkWell(
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => SecPage(s))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: green, width: 1.5),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(s.icon, size: 48, color: green),
          const SizedBox(height: 8),
          Text(t(s.name), style: const TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
      ),
    );

class SecPage extends StatefulWidget {
  final Sec s;
  const SecPage(this.s, {super.key});
  @override
  State<SecPage> createState() => _SecPageState();
}

class _SecPageState extends State<SecPage> {
  String? result;
  bool busy = false;

  Future<void> pick(ImageSource src) async {
    final x = await ImagePicker().pickImage(source: src, maxWidth: 1024, imageQuality: 70);
    if (x == null) return;
    setState(() {
      busy = true;
      result = null;
    });
    final r = await diagnose(File(x.path), t(widget.s.name));
    if (!mounted) return;
    setState(() {
      busy = false;
      result = r;
    });
  }

  Widget info(String title, String body, Color col) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 6),
            Text(body, style: TextStyle(color: col, fontSize: 15, height: 1.4)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext c) => ValueListenableBuilder<bool>(
        valueListenable: bn,
        builder: (c, _, __) {
          final s = widget.s;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: green,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(t(s.name), style: const TextStyle(color: Colors.white)),
              actions: [langBtn()],
            ),
            body: ListView(padding: const EdgeInsets.all(12), children: [
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: busy ? null : () => pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(t('ছবি তুলুন|Take photo')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: Text(t('গ্যালারি|Gallery')),
                  ),
                ),
              ]),
              if (busy) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: green))),
              if (result != null) info(t('রোগ শনাক্ত ও পরামর্শ|Diagnosis & advice'), result!, red),
              info(s.plant ? t('সার|Fertilizer') : t('খাদ্য|Feed'), t(s.feed), darkGreen),
              info(t('রোগ ও প্রতিকার|Diseases & remedy'), t(s.disease), red),
              info(s.plant ? t('লাগানো ও পরিচর্যা|Planting & care') : t('পালন ও পরিচর্যা|Rearing & care'), t(s.care), darkGreen),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  t('এটি সাধারণ পরামর্শ। গুরুতর হলে স্থানীয় কৃষি/প্রাণিসম্পদ/মৎস্য কর্মকর্তার পরামর্শ নিন।|This is general advice. For serious cases consult a local agriculture, livestock or fisheries officer.'),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ]),
          );
        },
      );
}

Future<String> diagnose(File f, String subject) async {
  try {
    final p = await SharedPreferences.getInstance();
    final key = p.getString('key') ?? '';
    if (key.isEmpty) return t('উপরের চাবি আইকনে এআই কী দিন।|Enter the AI key using the key icon on the home screen.');
    final b64 = base64Encode(await f.readAsBytes());
    final lang = bn.value ? 'Bangla' : 'English';
    final prompt = 'You are an agriculture and veterinary assistant for farmers in Bangladesh. The photo shows: $subject. '
        'Identify the likely disease or problem, the remedy, the suitable type of medicine or fertilizer (no exact doses) and feed advice. '
        'If the photo is unclear or the subject looks healthy, say so. Reply in $lang, short, as bullet points, and end by advising '
        'to consult a local agriculture, livestock or fisheries officer.';
    const model = 'gemini-2.5-flash';
    final r = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent'),
      headers: {'x-goog-api-key': key, 'content-type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'inline_data': {'mime_type': 'image/jpeg', 'data': b64}},
              {'text': prompt},
            ],
          }
        ],
      }),
    );
    if (r.statusCode != 200) return 'Error ${r.statusCode}';
    return jsonDecode(utf8.decode(r.bodyBytes))['candidates'][0]['content']['parts'][0]['text'] as String;
  } catch (e) {
    return t('সংযোগে সমস্যা হয়েছে।|Connection problem.');
  }
}

Future<void> keyDialog(BuildContext c) async {
  final p = await SharedPreferences.getInstance();
  final ctl = TextEditingController(text: p.getString('key') ?? '');
  if (!c.mounted) return;
  showDialog(
    context: c,
    builder: (d) => AlertDialog(
      title: Text(t('এআই কী|AI key')),
      content: TextField(controller: ctl, obscureText: true, decoration: const InputDecoration(hintText: 'AIza...')),
      actions: [
        TextButton(
          onPressed: () async {
            await p.setString('key', ctl.text.trim());
            if (d.mounted) Navigator.pop(d);
          },
          child: Text(t('সংরক্ষণ|Save')),
        ),
      ],
    ),
  );
}

void feedbackDialog(BuildContext c) {
  final ctl = TextEditingController();
  showDialog(
    context: c,
    builder: (d) => AlertDialog(
      title: Text(t('মতামত|Feedback')),
      content: TextField(controller: ctl, maxLines: 4, decoration: InputDecoration(hintText: t('আপনার মতামত লিখুন|Write your feedback'))),
      actions: [
        TextButton(
          onPressed: () async {
            await launchUrl(Uri.parse('sms:$phone?body=${Uri.encodeComponent(ctl.text)}'));
            if (d.mounted) Navigator.pop(d);
          },
          child: Text(t('পাঠান|Send')),
        ),
      ],
    ),
  );
}
