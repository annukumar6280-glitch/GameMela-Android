import 'games/mini_games.dart';
import 'services/backend.dart';
import 'ads/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameMelaBackend.initialize();
  runApp(const GameMelaApp());
}

const navy = Color(0xFF090F1F);
const panel = Color(0xFF141E33);
const gold = Color(0xFFFFC857);
const blue = Color(0xFF38BDF8);
const _bikeSimulatorChannel = MethodChannel('gamemela/bike_simulator');

class GameMelaApp extends StatelessWidget {
  const GameMelaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'GameMela',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navy,
      colorScheme: const ColorScheme.dark(primary: gold, secondary: blue, surface: panel),
      useMaterial3: true,
      fontFamily: 'Roboto',
    ),
    home: const HomeScreen(),
  );
}

class GameInfo {
  final String title, subtitle, emoji;
  final Color color;
  const GameInfo(this.title, this.subtitle, this.emoji, this.color);
}

const games = <GameInfo>[
  GameInfo('Bike', '3D open-road motorcycle simulator', '🏍️', Color(0xFFFB923C)),
  GameInfo('Car', '3D open-road driving simulator', '🚗', Color(0xFF60A5FA)),
  GameInfo('Train', '3D railway driving simulator', '🚆', Color(0xFF34D399)),
  GameInfo('Plane', '3D flight simulator', '✈️', Color(0xFFA78BFA)),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const HomeContent(), const GamesContent(), const GarageContent()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF10192B),
        indicatorColor: gold.withValues(alpha: .16),
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Games'),
          NavigationDestination(icon: Icon(Icons.garage_rounded), label: 'Garage'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
    children: [
      Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [gold, Color(0xFFFF8C42)]),
          borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.sports_esports_rounded, color: navy, size: 27)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('GAMEMELA', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 2)),
          Text('Play • Challenge • Win', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        const CoinPill(),
      ]),
      const SizedBox(height: 26),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF203B63), Color(0xFF17213A), Color(0xFF34264A)]),
          border: Border.all(color: Colors.white.withValues(alpha: .10)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR NEXT\nLEVEL STARTS HERE', style: TextStyle(fontSize: 25, height: 1.15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('Puzzles, challenges and racing — all in one place.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: navy),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesScreen())),
            icon: const Icon(Icons.play_arrow_rounded), label: const Text('EXPLORE GAMES', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
      const RewardedCoinsCard(),
      const SizedBox(height: 25),
      const SectionTitle('Featured games', 'Pick your challenge'),
      const SizedBox(height: 13),
      SizedBox(height: 158, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(width: 145, child: GameCard(game: games[i])),
      )),
      const SizedBox(height: 24),
      const SectionTitle('Your journey', 'More adventures ahead'),
      const SizedBox(height: 12),
      const Row(children: [
        Expanded(child: StatCard(icon: Icons.sports_esports, label: 'Games', value: '4')),
        SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '0 days')),
        SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.emoji_events, label: 'Wins', value: '0')),
      ]),
      const SizedBox(height: 15),
      const Text('Open Garage to create your player account and sync Coins and progress.', style: TextStyle(color: Colors.white38, fontSize: 11)),
      const GameMelaBannerAd(),
    ],
  );
}


class RewardedCoinsCard extends StatefulWidget {
  const RewardedCoinsCard({super.key});

  @override
  State<RewardedCoinsCard> createState() => _RewardedCoinsCardState();
}

class _RewardedCoinsCardState extends State<RewardedCoinsCard> {
  bool busy = false;

  Future<void> _watchAd() async {
    if (!GameMelaBackend.ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('20 Coins पाने के लिए पहले Garage में account बनाइए या sign in कीजिए।')),
      );
      return;
    }
    setState(() => busy = true);
    try {
      final startingCoins = GameMelaBackend.coins.value;
      final customData = await GameMelaBackend.createRewardedAdSession();
      final earned = await GameMelaAds.showRewardedAd(customData: customData);
      if (!mounted) return;
      if (!earned) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('विज्ञापन पूरा नहीं हुआ। Coins नहीं जोड़े गए।')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('विज्ञापन पूरा हुआ। 20 Coins की सुरक्षित पुष्टि हो रही है...')),
      );

      var credited = false;
      for (var attempt = 0; attempt < 6; attempt++) {
        await Future.delayed(const Duration(seconds: 2));
        await GameMelaBackend.refreshCoins();
        if (GameMelaBackend.coins.value >= startingCoins + 20) {
          credited = true;
          break;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(credited
              ? 'बधाई! 20 Coins आपके खाते में जुड़ गए।'
              : 'सत्यापन अभी जारी है। थोड़ी देर बाद Coins अपने-आप अपडेट होंगे।'),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 18),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      gradient: const LinearGradient(
        colors: [Color(0xFF263A63), Color(0xFF20213F)],
      ),
      border: Border.all(color: gold.withValues(alpha: .35)),
    ),
    child: Row(children: [
      const Text('🎁', style: TextStyle(fontSize: 34)),
      const SizedBox(width: 12),
      const Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FREE 20 COINS', style: TextStyle(color: gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
          SizedBox(height: 4),
          Text('Watch a rewarded ad and earn 20 Coins', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      )),
      FilledButton(
        onPressed: busy ? null : _watchAd,
        style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: navy),
        child: Text(busy ? 'PLEASE WAIT' : 'WATCH'),
      ),
    ]),
  );
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('All Games', style: TextStyle(fontWeight: FontWeight.bold))),
    body: const GamesContent(),
  );
}

class GamesContent extends StatelessWidget {
  const GamesContent({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text('CHOOSE YOUR GAME', style: TextStyle(color: gold, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 7),
      const Text('What are you playing today?', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 17),
      ...games.map((g) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GameCard(game: g, horizontal: true),
      )),
      const GameMelaBannerAd(),
    ],
  );
}

class GarageContent extends StatefulWidget {
  const GarageContent({super.key});
  @override
  State<GarageContent> createState() => _GarageContentState();
}

class _GarageContentState extends State<GarageContent> {
  String vehicleType = 'bike';
  List<Map<String, dynamic>> vehicles = [];
  bool loading = true;
  String? busy;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => loading = true);
    try { vehicles = await GameMelaBackend.loadVehicles(); }
    catch (_) { vehicles = []; }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _action(String key, Future<void> Function() action) async {
    setState(() => busy = key);
    try {
      await action();
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Garage updated successfully')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    } finally { if (mounted) setState(() => busy = null); }
  }

  @override
  Widget build(BuildContext context) {
    final owned = vehicles.where((v) => v['vehicle_type'] == vehicleType).toList();
    final isBike = vehicleType == 'bike';
    return ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
      const Text('YOUR GARAGE', style: TextStyle(color: gold, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Build your dream ride', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      ValueListenableBuilder<int>(valueListenable: GameMelaBackend.coins, builder: (_, value, __) => Align(alignment: Alignment.centerLeft, child: CoinPill(value: value))),
      const SizedBox(height: 12),
      if (!GameMelaBackend.ready) _AccountPanel(onConnected: _load)
      else Row(children: [const Icon(Icons.cloud_done, color: Colors.greenAccent, size: 18), const SizedBox(width: 6), const Expanded(child: Text('Cloud account connected', style: TextStyle(color: Colors.greenAccent, fontSize: 12))), TextButton(onPressed: () async { await GameMelaBackend.signOut(); await _load(); }, child: const Text('SIGN OUT'))]),
      const SizedBox(height: 16),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'bike', label: Text('Bikes'), icon: Icon(Icons.two_wheeler)),
          ButtonSegment(value: 'car', label: Text('Cars'), icon: Icon(Icons.directions_car)),
        ],
        selected: {vehicleType},
        onSelectionChanged: (values) => setState(() => vehicleType = values.first),
      ),
      const SizedBox(height: 18),
      Text('YOUR ${isBike ? 'BIKES' : 'CARS'}', style: const TextStyle(color: gold, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      if (loading) const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()))
      else if (owned.isEmpty) const Text('No vehicles yet. Unlock your first ride below.', style: TextStyle(color: Colors.white54))
      else ...owned.map((v) => _ownedVehicle(v)),
      const SizedBox(height: 22),
      Text('UNLOCK NEW ${isBike ? 'BIKES' : 'CARS'}', style: const TextStyle(color: gold, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...List.generate(5, (i) {
        final number = i + 1;
        final id = '${vehicleType}_$number';
        final price = isBike ? 500 + i * 100 : 1000 + i * 200;
        final has = vehicles.any((v) => v['model_id'] == id);
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          child: Row(children: [
            Text(isBike ? '🏍️' : '🏎️', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${isBike ? 'Bike' : 'Car'} Model $number', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$price Coins', style: const TextStyle(color: gold, fontSize: 12)),
            ])),
            if (has) const Text('OWNED', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11))
            else FilledButton(
              onPressed: busy == id || !GameMelaBackend.ready ? null : () => _action(id, () => GameMelaBackend.purchaseVehicle(vehicleType, id)),
              child: Text(busy == id ? '...' : 'BUY'),
            ),
          ]),
        );
      }),
      if (!GameMelaBackend.ready)
        const Padding(padding: EdgeInsets.only(top: 10), child: Text('Cloud profile is not connected yet. Check your internet connection and reopen the app.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12))),
      const GameMelaBannerAd(),
    ]);
  }

  Widget _ownedVehicle(Map<String, dynamic> v) {
    final upgrades = Map<String, dynamic>.from(v['upgrades'] as Map? ?? {});
    final durability = (v['durability'] as num?)?.toInt() ?? 100;
    final id = v['id'].toString();
    final model = (v['model_id'] as String).split('_').last;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: gold.withValues(alpha: .25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(v['vehicle_type'] == 'bike' ? '🏍️' : '🏎️', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 10),
          Expanded(child: Text('${v['vehicle_type'] == 'bike' ? 'Bike' : 'Car'} Model $model', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Text('$durability%', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: durability / 100, minHeight: 6, borderRadius: BorderRadius.circular(5)),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(
          onPressed: durability == 100 || busy == 'repair_$id' ? null : () => _action('repair_$id', () => GameMelaBackend.repairVehicle(id)),
          icon: const Icon(Icons.build_circle_outlined), label: Text(durability == 100 ? 'FULLY REPAIRED' : 'REPAIR · ${(100-durability)*10} COINS'),
        )),
        const Divider(color: Colors.white12),
        ...['speed','handling','engine','brakes'].map((stat) {
          final level = (upgrades[stat] as num?)?.toInt() ?? 0;
          final cost = (level + 1) * 100;
          return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
            Expanded(child: Text('${stat[0].toUpperCase()} ${stat.substring(1)}  ·  Lv $level/50', style: const TextStyle(fontSize: 12))),
            TextButton(
              onPressed: level >= 50 || busy == '${id}_$stat' ? null : () => _action('${id}_$stat', () => GameMelaBackend.upgradeVehicle(id, stat)),
              child: Text(level >= 50 ? 'MAX' : 'UPGRADE · $cost'),
            ),
          ]));
        }),
        if (v['vehicle_type'] == 'bike')
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                try {
                  await _bikeSimulatorChannel.invokeMethod<void>('launchBikeSimulator');
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('3D Bike Simulator could not open: $error')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('RIDE NOW · 3D SIMULATOR'),
              style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
      ]),
    );
  }
}


class _AccountPanel extends StatefulWidget {
  final VoidCallback onConnected;
  const _AccountPanel({required this.onConnected});
  @override
  State<_AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends State<_AccountPanel> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool creating = true;
  bool busy = false;

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email and a password with at least 6 characters.')));
      return;
    }
    setState(() => busy = true);
    try {
      if (creating) {
        final connected = await GameMelaBackend.signUp(email.text, password.text);
        if (!connected && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created. Check your email to confirm it, then sign in here.')));
          setState(() => creating = false);
        } else if (connected) {
          widget.onConnected();
        }
      } else {
        await GameMelaBackend.signIn(email.text, password.text);
        widget.onConnected();
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(17), border: Border.all(color: gold.withValues(alpha: .22))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(creating ? 'SAVE YOUR GAME PROGRESS' : 'WELCOME BACK', style: const TextStyle(color: gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 5),
      const Text('Create an account to keep Coins, scores and vehicles safe across sessions.', style: TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 12),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 9),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password (6+ characters)', prefixIcon: Icon(Icons.lock_outline))),
      const SizedBox(height: 12),
      FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'PLEASE WAIT...' : creating ? 'CREATE ACCOUNT' : 'SIGN IN')),
      TextButton(onPressed: busy ? null : () => setState(() => creating = !creating), child: Text(creating ? 'Already have an account? Sign in' : 'New player? Create an account')),
    ]),
  );
}

class GameCard extends StatelessWidget {
  final GameInfo game;
  final bool horizontal;
  const GameCard({super.key, required this.game, this.horizontal = false});
  @override
  Widget build(BuildContext context) {
    final content = Row(children: [
      Container(width: 58, height: 58, decoration: BoxDecoration(
        color: game.color.withValues(alpha: .15), borderRadius: BorderRadius.circular(17)),
        alignment: Alignment.center, child: Text(game.emoji, style: const TextStyle(fontSize: 31))),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(game.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text(game.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 8),
        Text('TAP TO PLAY', style: TextStyle(color: game.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ])),
      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
    ]);
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: () async {
        if (game.title == 'Bike') {
          try {
            await _bikeSimulatorChannel.invokeMethod<void>('launchBikeSimulator');
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('3D Bike Simulator could not open: $error')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${game.title} का 3D simulator अभी development में है।')),
          );
        }
      },
      child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(19),
        border: Border.all(color: game.color.withValues(alpha: .20))),
      child: horizontal ? content : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(game.emoji, style: const TextStyle(fontSize: 35)),
        const Spacer(),
        Text(game.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(game.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ]),
      ),
    );
  }
}

class CoinPill extends StatelessWidget {
  final int? value;
  const CoinPill({super.key, this.value});
  @override
  Widget build(BuildContext context) {
    if (value != null) return _coinView(value!);
    return ValueListenableBuilder<int>(
      valueListenable: GameMelaBackend.coins,
      builder: (_, amount, __) => _coinView(amount),
    );
  }
  Widget _coinView(int amount) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(30), border: Border.all(color: gold.withValues(alpha: .4))),
    child: Row(children: [
      const Icon(Icons.monetization_on, color: gold, size: 18),
      const SizedBox(width: 5),
      Text('$amount', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
    ]),
  );
}

class SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const SectionTitle(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
    const SizedBox(height: 3),
    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
  ]);
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const StatCard({super.key, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15)),
    child: Column(children: [
      Icon(icon, color: gold, size: 19),
      const SizedBox(height: 7),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ]),
  );
}
