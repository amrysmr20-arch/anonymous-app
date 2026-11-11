import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(const AnonymousApp());

const redAccent = Color(0xFFE50914);
const goldAccent = Color(0xFFD4AF37);
const darkCard = Color(0xFF141414);
const bgBlack = Color(0xFF050505);
const apiUrl = 'http://node-michie.jkt48node.id:3721';

class AnonymousApp extends StatelessWidget {
  const AnonymousApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANONYMOUS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: bgBlack, primaryColor: redAccent, fontFamily: 'monospace'),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final pages = [
    const HomeTab(),
    const Center(child: Text('INFO', style: TextStyle(color: Colors.white))),
    const WhatsAppToolsScreen(),
    const Center(child: Text('NOTIFIKASI', style: TextStyle(color: Colors.white))),
    const Center(child: Text('TOOLS LAINNYA', style: TextStyle(color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text('ANONYMOUS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(icon: const Icon(Icons.link, color: goldAccent), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PairingScreen()))),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[800]!)),
            child: const Row(children: [CircleAvatar(radius: 8, backgroundColor: redAccent), SizedBox(width: 8), Text('YUNDA', style: TextStyle(color: Colors.white, fontSize: 12))]),
          )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF0A0A0A), selectedItemColor: goldAccent, unselectedItemColor: Colors.white30, type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Info'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Whatsapp'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notif'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: redAccent.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('WELCOME BACK,', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 4),
          const Text('JESS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.circle, color: Colors.green, size: 10), const SizedBox(width: 6), Text('ACTIVE · SECURE SESSION', style: TextStyle(color: Colors.white54, fontSize: 10))]),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text('DEV: YUNDA', style: TextStyle(color: redAccent, fontSize: 10, fontWeight: FontWeight.bold)))
        ]),
      ),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())),
        child: Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: goldAccent.withOpacity(0.3))),
          child: Row(children: [CircleAvatar(backgroundColor: goldAccent.withOpacity(0.2), child: const Icon(Icons.menu_book, color: goldAccent)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Al-Qur'an", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('114 Surah', style: TextStyle(color: Colors.white54, fontSize: 10))])), const Icon(Icons.chevron_right, color: Colors.white30)]),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VinylScreen())),
        child: Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: redAccent.withOpacity(0.3))),
          child: Row(children: [CircleAvatar(backgroundColor: redAccent.withOpacity(0.2), child: const Icon(Icons.album, color: redAccent)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Vinyl Player", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('Audio Simulation', style: TextStyle(color: Colors.white54, fontSize: 10))])), const Icon(Icons.chevron_right, color: Colors.white30)]),
        ),
      ),
    ]);
  }
}

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});
  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _phoneCtrl = TextEditingController();
  String _sender = 'pribadi';
  String? _code;
  bool _loading = false;
  bool _pribadiConnected = false;
  bool _globalConnected = false;
  Timer? _poll;

  @override
  void initState() { super.initState(); _checkStatus(); _poll = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus()); }
  @override
  void dispose() { _poll?.cancel(); super.dispose(); }

  Future<void> _checkStatus() async {
    try {
      final res = await http.get(Uri.parse('$apiUrl/api/status'));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        setState(() { _pribadiConnected = d['pribadi'] == true; _globalConnected = d['global'] == true; });
      }
    } catch (_) {}
  }

  Future<void> _requestCode() async {
    if (_phoneCtrl.text.isEmpty) return;
    setState(() { _loading = true; _code = null; });
    try {
      final res = await http.post(Uri.parse('$apiUrl/api/pair'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'sender': _sender, 'phone': _phoneCtrl.text}));
      final d = jsonDecode(res.body);
      if (d['pairingCode'] != null) setState(() => _code = d['pairingCode']);
      else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(d['error'] ?? 'Gagal')));
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack, appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('PAIRING SENDER', style: TextStyle(color: redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)), iconTheme: const IconThemeData(color: redAccent)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _statusRow('PRIBADI', _pribadiConnected), const SizedBox(height: 8), _statusRow('GLOBAL', _globalConnected), const SizedBox(height: 24),
        const Text('1. PILIH SENDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        Row(children: ['pribadi', 'global'].map((s) {
          bool a = _sender == s;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _sender = s), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: a ? redAccent.withOpacity(0.15) : darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: a ? redAccent : Colors.grey[800]!)), child: Center(child: Text(s.toUpperCase(), style: TextStyle(color: a ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))))));
        }).toList()),
        const SizedBox(height: 20),
        const Text('2. MASUKKAN NOMOR WHATSAPP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: '628123456789', filled: true, fillColor: darkCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: redAccent)))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _loading ? null : _requestCode, style: ElevatedButton.styleFrom(backgroundColor: redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('MINTA KODE PAIRING', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)))),
        if (_code != null) ...[
          const SizedBox(height: 24),
          Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: goldAccent), boxShadow: [BoxShadow(color: goldAccent.withOpacity(0.3), blurRadius: 20)]), child: Column(children: [const Text('KODE PAIRING', style: TextStyle(color: goldAccent, fontSize: 12, letterSpacing: 3)), const SizedBox(height: 12), SelectableText(_code!, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 6)), const SizedBox(height: 16), const Text('Buka WhatsApp > Perangkat Tertaut > Tautkan dengan nomor telepon.', style: TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center)]))
        ]
      ])),
    );
  }
  Widget _statusRow(String label, bool connected) => Row(children: [Icon(Icons.circle, size: 10, color: connected ? Colors.green : Colors.red), const SizedBox(width: 8), Text('SENDER $label: ${connected ? "TERHUBUNG" : "OFFLINE"}', style: TextStyle(color: connected ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold))]);
}

class WhatsAppToolsScreen extends StatefulWidget {
  const WhatsAppToolsScreen({super.key});
  @override
  State<WhatsAppToolsScreen> createState() => _WhatsAppToolsScreenState();
}

class _WhatsAppToolsScreenState extends State<WhatsAppToolsScreen> {
  final TextEditingController _targetController = TextEditingController();
  String _selectedCommand = 'BANNUMBERV1';
  String _selectedSender = 'pribadi';
  bool _isLoading = false;
  final List<String> _commands = ['BANNUMBERV1', 'DELAYV1', 'DELAYV2', 'LOCKCHT', 'LOCK_GROUP'];

  Future<void> _sendBug() async {
    if (_targetController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final res = await http.post(Uri.parse('$apiUrl/api/send-bug'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'target': _targetController.text, 'command': _selectedCommand, 'senderType': _selectedSender}));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status: ${jsonDecode(res.body)['status']}')));
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); } finally { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('TARGET NUMBER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      TextField(controller: _targetController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: '+62812xxxxxxx', filled: true, fillColor: darkCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: redAccent)))),
      const SizedBox(height: 20), const Text('SELECT COMMAND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _commands.map((cmd) {
        bool a = _selectedCommand == cmd;
        return GestureDetector(onTap: () => setState(() => _selectedCommand = cmd), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: a ? redAccent : darkCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: a ? Colors.red : Colors.grey[800]!), boxShadow: a ? [BoxShadow(color: redAccent.withOpacity(0.5), blurRadius: 10)] : []), child: Text(cmd, style: TextStyle(color: a ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))));
      }).toList()),
      const SizedBox(height: 20), const Text('SELECT SENDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Row(children: ['pribadi', 'global'].map((s) {
        bool a = _selectedSender == s;
        return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedSender = s), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: a ? Colors.grey[900] : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: a ? redAccent : Colors.grey[800]!)), child: Column(children: [Icon(s == 'pribadi' ? Icons.person : Icons.public, color: a ? redAccent : Colors.grey), const SizedBox(height: 4), Text(s.toUpperCase(), style: TextStyle(color: a ? Colors.white : Colors.grey, fontSize: 12))]))));
      }).toList()),
      const SizedBox(height: 30),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _sendBug, style: ElevatedButton.styleFrom(backgroundColor: redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SEND BUG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)))),
      const SizedBox(height: 20), Center(child: Text('DEV: YUNDA', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, letterSpacing: 4))),
    ]));
  }
}

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<dynamic> _surahs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    try {
      final res = await http.get(Uri.parse('https://equran.id/api/surat'));
      if (res.statusCode == 200) setState(() => _surahs = jsonDecode(res.body));
    } catch (e) {} finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: bgBlack, title: const Text("Al-Qur'an", style: TextStyle(color: goldAccent)), iconTheme: const IconThemeData(color: goldAccent)), body: _loading ? const Center(child: CircularProgressIndicator(color: goldAccent)) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _surahs.length, itemBuilder: (c, i) {
      final s = _surahs[i];
      return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[900]!)), child: ListTile(leading: CircleAvatar(backgroundColor: goldAccent.withOpacity(0.2), child: Text('${s['nomor']}', style: const TextStyle(color: goldAccent, fontSize: 12))), title: Text(s['nama_latin'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text('${s['arti']} · ${s['jumlah_ayat']} Ayat', style: const TextStyle(color: Colors.white54, fontSize: 11))));
    }));
  }
}

class VinylScreen extends StatefulWidget {
  const VinylScreen({super.key});
  @override
  State<VinylScreen> createState() => _VinylScreenState();
}

class _VinylScreenState extends State<VinylScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(); }
  @override
  void dispose() { _ctrl.dispose(); _player.dispose(); super.dispose(); }

  Future<void> _toggle() async {
    if (_isPlaying) { await _player.pause(); _ctrl.stop(); } else { await _player.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')); _ctrl.repeat(); }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: bgBlack, appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('VINYL PLAYER', style: TextStyle(color: redAccent)), iconTheme: const IconThemeData(color: redAccent)), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      RotationTransition(turns: _ctrl, child: Container(width: 250, height: 250, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.black, Color(0xFF1A1A1A), Colors.black], stops: [0.2, 0.8, 1.0]), boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 30, spreadRadius: 10)]), child: Stack(alignment: Alignment.center, children: [Container(width: 70, height: 70, decoration: const BoxDecoration(shape: BoxShape.circle, color: redAccent), child: const Center(child: Icon(Icons.music_note, color: Colors.white, size: 30))), Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black))]))),
      const SizedBox(height: 50), Text(_isPlaying ? 'NOW PLAYING...' : 'PAUSED', style: const TextStyle(color: goldAccent, letterSpacing: 4, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30), GestureDetector(onTap: _toggle, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(shape: BoxShape.circle, color: darkCard, border: Border.all(color: redAccent, width: 2), boxShadow: [BoxShadow(color: redAccent.withOpacity(0.3), blurRadius: 20)]), child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: redAccent, size: 40))),
    ])));
  }
}
