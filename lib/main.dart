import 'games/mini_games.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GameMelaApp());

const navy = Color(0xFF090F1F);
const panel = Color(0xFF141E33);
const gold = Color(0xFFFFC857);
const blue = Color(0xFF38BDF8);

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
  GameInfo('Bubble Pop', 'Pop bubbles • Relax & play', '🫧', Color(0xFF38BDF8)),
  GameInfo('Quiz Challenge', 'Test your knowledge', '🧠', Color(0xFFA78BFA)),
  GameInfo('Memory Match', 'Match the hidden pairs', '🃏', Color(0xFFF472B6)),
  GameInfo('Number Puzzle', 'Train your brain', '🔢', Color(0xFF34D399)),
  GameInfo('Word Puzzle', 'Find the hidden words', '🔤', Color(0xFFFBBF24)),
  GameInfo('Bike Racing', 'Race on two wheels', '🏍️', Color(0xFFFB923C)),
  GameInfo('Car Racing', 'Own the track', '🏎️', Color(0xFF60A5FA)),
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
        Expanded(child: StatCard(icon: Icons.sports_esports, label: 'Games', value: '7')),
        SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '0 days')),
        SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.emoji_events, label: 'Wins', value: '0')),
      ]),
      const SizedBox(height: 15),
      const Text('Coins and progress will appear here when your player profile is connected.', style: TextStyle(color: Colors.white38, fontSize: 11)),
    ],
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
    ],
  );
}

class GarageContent extends StatelessWidget {
  const GarageContent({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('YOUR GARAGE', style: TextStyle(color: gold, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Build your dream ride', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
    const SizedBox(height: 20),
    _garageTile('🏍️', 'Bike Collection', 'Models, upgrades and repairs'),
    const SizedBox(height: 12),
    _garageTile('🏎️', 'Car Collection', 'Choose and tune your cars'),
    const SizedBox(height: 20),
    const Text('Earn Coins in games, then use them to unlock vehicles and upgrades. Garage purchases will be enabled in the next development stage.', style: TextStyle(color: Colors.white54, height: 1.5)),
  ]);
}

Widget _garageTile(String emoji, String title, String subtitle) => Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
  child: Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 34)),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ])),
    const Icon(Icons.chevron_right_rounded, color: gold),
  ]),
);

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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => gameForTitle(game.title))),
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
  const CoinPill({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(30), border: Border.all(color: gold.withValues(alpha: .4))),
    child: const Row(children: [Icon(Icons.monetization_on, color: gold, size: 18), SizedBox(width: 5), Text('0', style: TextStyle(color: gold, fontWeight: FontWeight.bold))]),
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
