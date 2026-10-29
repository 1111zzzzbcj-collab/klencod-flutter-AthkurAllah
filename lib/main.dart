import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AthkurAllahApp());
}

class AthkurAllahApp extends StatelessWidget {
  const AthkurAllahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اذكر الله',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1713),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15966B),
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const TasbeehHome(),
    );
  }
}

class Dhikr {
  final String text;
  final String category;
  final String meaning;

  const Dhikr({
    required this.text,
    required this.category,
    required this.meaning,
  });
}

const List<Dhikr> adhkar = [
  Dhikr(
    text: 'سبحان الله',
    category: 'التسبيح',
    meaning: 'تنزيه الله تعالى عن كل نقص.',
  ),
  Dhikr(
    text: 'سبحان الله العظيم',
    category: 'التسبيح',
    meaning: 'تنزيه الله العظيم عن كل نقص.',
  ),
  Dhikr(
    text: 'سبحان الله وبحمده',
    category: 'التسبيح',
    meaning: 'تنزيه الله وحمده والثناء عليه.',
  ),
  Dhikr(
    text: 'سبحان الله العظيم وبحمده',
    category: 'التسبيح',
    meaning: 'تنزيه الله العظيم وحمده.',
  ),
  Dhikr(
    text: 'الحمد لله',
    category: 'التحميد',
    meaning: 'الثناء على الله وحمده على نعمه.',
  ),
  Dhikr(
    text: 'الله أكبر',
    category: 'التكبير',
    meaning: 'الله أعظم من كل شيء.',
  ),
  Dhikr(
    text: 'لا إله إلا الله',
    category: 'التهليل',
    meaning: 'لا معبود بحق إلا الله.',
  ),
  Dhikr(
    text: 'لا حول ولا قوة إلا بالله',
    category: 'أذكار متنوعة',
    meaning: 'لا تحول عن معصية ولا قوة على طاعة إلا بالله.',
  ),
  Dhikr(
    text: 'أستغفر الله',
    category: 'الاستغفار',
    meaning: 'طلب المغفرة من الله تعالى.',
  ),
  Dhikr(
    text: 'أستغفر الله العظيم وأتوب إليه',
    category: 'الاستغفار',
    meaning: 'طلب المغفرة والرجوع إلى الله بالتوبة.',
  ),
  Dhikr(
    text: 'اللهم صل وسلم على نبينا محمد',
    category: 'الصلاة على النبي',
    meaning: 'الصلاة والسلام على النبي محمد ﷺ.',
  ),
  Dhikr(
    text: 'حسبي الله ونعم الوكيل',
    category: 'أذكار متنوعة',
    meaning: 'الله كافيني، وهو خير من أتوكل عليه.',
  ),
  Dhikr(
    text: 'لا إله إلا أنت سبحانك إني كنت من الظالمين',
    category: 'أدعية قرآنية',
    meaning: 'دعاء يونس عليه السلام المذكور في القرآن الكريم.',
  ),
  Dhikr(
    text: 'اللهم أعني على ذكرك وشكرك وحسن عبادتك',
    category: 'أدعية نبوية',
    meaning: 'دعاء بطلب العون على الذكر والشكر والعبادة.',
  ),
];

class TasbeehHome extends StatefulWidget {
  const TasbeehHome({super.key});

  @override
  State<TasbeehHome> createState() => _TasbeehHomeState();
}

class _TasbeehHomeState extends State<TasbeehHome> {
  int count = 0;
  int total = 0;
  int goal = 33;
  int lastCount = 0;
  int lastTotal = 0;
  int selectedIndex = 0;
  bool vibrationEnabled = true;

  Color beadColor = const Color(0xFF15966B);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      count = prefs.getInt('tasbeeh_count') ?? 0;
      total = prefs.getInt('tasbeeh_total') ?? 0;
      goal = prefs.getInt('tasbeeh_goal') ?? 33;
      selectedIndex = prefs.getInt('selected_dhikr') ?? 0;

      if (selectedIndex < 0 || selectedIndex >= adhkar.length) {
        selectedIndex = 0;
      }

      if (goal < 1) goal = 33;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('tasbeeh_count', count);
    await prefs.setInt('tasbeeh_total', total);
    await prefs.setInt('tasbeeh_goal', goal);
    await prefs.setInt('selected_dhikr', selectedIndex);
  }

  void _increment() {
    setState(() {
      lastCount = count;
      lastTotal = total;

      count++;
      total++;
    });

    if (vibrationEnabled) {
      HapticFeedback.selectionClick();
    }

    _saveData();

    if (count == goal && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أحسنت! أكملت $goal من ${adhkar[selectedIndex].text}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _undo() {
    if (count == 0 || total == 0) return;

    setState(() {
      count = lastCount;
      total = lastTotal;
    });

    _saveData();
  }

  Future<void> _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة العداد'),
        content: const Text('هل تريد تصفير عداد الذكر الحالي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تصفير'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      count = 0;
      lastCount = 0;
      lastTotal = total;
    });

    await _saveData();
  }

  Future<void> _chooseDhikr() async {
    final chosen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'اختر الذكر',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            for (int i = 0; i < adhkar.length; i++)
              ListTile(
                title: Text(
                  adhkar[i].text,
                  textAlign: TextAlign.right,
                ),
                subtitle: Text(
                  adhkar[i].category,
                  textAlign: TextAlign.right,
                ),
                onTap: () => Navigator.pop(context, i),
              ),
          ],
        ),
      ),
    );

    if (chosen == null || !mounted) return;

    setState(() {
      selectedIndex = chosen;
      count = 0;
      lastCount = 0;
    });

    await _saveData();
  }

  Future<void> _chooseGoal() async {
    final controller = TextEditingController(text: '$goal');

    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('هدف التسبيح'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'عدد التكرارات',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              if (parsed != null && parsed > 0) {
                Navigator.pop(context, parsed);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (value == null || !mounted) return;

    setState(() => goal = value);
    await _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = adhkar[selectedIndex];
    final progress = (count / goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اذكر الله',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'الاهتزاز',
            onPressed: () {
              setState(() => vibrationEnabled = !vibrationEnabled);
            },
            icon: Icon(
              vibrationEnabled
                  ? Icons.vibration
                  : Icons.phone_android,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Text(
              'بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                height: 1.8,
                color: Color(0xFF8EE0B8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ يومك بذكر الله',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 28),
            Card(
              color: const Color(0xFF142720),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      dhikr.category,
                      style: TextStyle(color: beadColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dhikr.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dhikr.meaning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _chooseDhikr,
                      icon: const Icon(Icons.menu_book),
                      label: const Text('اختيار ذكر آخر'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _increment,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF13231D),
                    border: Border.all(color: beadColor, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: beadColor.withOpacity(0.22),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        size: 32,
                        color: Color(0xFF8EE0B8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'من $goal',
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: beadColor,
                backgroundColor: Colors.white12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'إجمالي ضغطاتك: $total',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _chooseGoal,
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('الهدف'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _undo,
                    icon: const Icon(Icons.undo),
                    label: const Text('تراجع'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تصفير'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  beadColor = beadColor == const Color(0xFF15966B)
                      ? const Color(0xFF58A6FF)
                      : beadColor == const Color(0xFF58A6FF)
                          ? const Color(0xFFC08A56)
                          : const Color(0xFF15966B);
                });
              },
              icon: const Icon(Icons.palette_outlined),
              label: const Text('تغيير لون المسبحة'),
            ),
            const SizedBox(height: 24),
            const Text(
              'من صنع خالد الشامي',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}