import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

const _gold = Color(0xFFFFC857);
const _panel = Color(0xFF141E33);

Widget gameForTitle(String title) {
  switch (title) {
    case 'Bubble Pop': return const BubblePopGame();
    case 'Quiz Challenge': return const QuizGame();
    case 'Memory Match': return const MemoryGame();
    case 'Number Puzzle': return const NumberPuzzleGame();
    case 'Word Puzzle': return const WordPuzzleGame();
    case 'Bike Racing': return const RaceGame(vehicle: 'Bike');
    default: return const RaceGame(vehicle: 'Car');
  }
}

class _GameScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const _GameScaffold(this.title, this.child);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: child)),
  );
}

class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});
  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}
class _BubblePopGameState extends State<BubblePopGame> {
  int score = 0;
  List<int> bubbles = List.generate(24, (i) => i);
  void reset() => setState(() { score = 0; bubbles = List.generate(24, (i) => i); });
  @override
  Widget build(BuildContext context) => _GameScaffold('Bubble Pop', Column(children: [
    Text('Score: $score', style: const TextStyle(fontSize: 24, color: _gold, fontWeight: FontWeight.bold)),
    const SizedBox(height: 18),
    Expanded(child: GridView.builder(
      itemCount: 24, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemBuilder: (context, i) => bubbles.contains(i)
        ? InkWell(onTap: () => setState(() { bubbles.remove(i); score += 5; }), borderRadius: BorderRadius.circular(50),
            child: Container(decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.lightBlueAccent.withValues(alpha:.9), Colors.blue.shade900]), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(2,4))]), child: const Icon(Icons.circle, color: Colors.white24)))
        : const SizedBox.shrink(),
    )),
    if (bubbles.isEmpty) const Text('Great popping! You cleared the board.', style: TextStyle(color: _gold)),
    const SizedBox(height: 12), FilledButton(onPressed: reset, child: const Text('Play Again')),
  ]));
}

class QuizGame extends StatefulWidget {
  const QuizGame({super.key});
  @override
  State<QuizGame> createState() => _QuizGameState();
}
class _QuizGameState extends State<QuizGame> {
  final questions = const [
    ('Which planet is known as the Red Planet?', ['Venus','Mars','Jupiter','Mercury'], 1),
    ('How many sides does a hexagon have?', ['Five','Six','Seven','Eight'], 1),
    ('Which animal is the largest mammal?', ['Elephant','Blue whale','Giraffe','Shark'], 1),
    ('What is 9 × 7?', ['56','63','72','49'], 1),
    ('Which gas do plants absorb?', ['Oxygen','Nitrogen','Carbon dioxide','Hydrogen'], 2),
  ];
  int index = 0, score = 0;
  bool finished = false;
  @override
  Widget build(BuildContext context) {
    if (finished) return _GameScaffold('Quiz Challenge', Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.emoji_events, color: _gold, size: 64), const SizedBox(height: 12),
      Text('Your score: $score / ${questions.length}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18), FilledButton(onPressed: () => setState(() { index=0; score=0; finished=false; }), child: const Text('Try Again')),
    ])));
    final q = questions[index];
    return _GameScaffold('Quiz Challenge', Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('QUESTION ${index+1} OF ${questions.length}', style: const TextStyle(color: _gold, letterSpacing: 2)),
      const SizedBox(height: 18), Text(q.$1, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: FilledButton.tonal(
        onPressed: () => setState(() { if (i == q.$3) score++; index++; if (index == questions.length) finished=true; }),
        child: Padding(padding: const EdgeInsets.all(10), child: Text(q.$2[i], style: const TextStyle(fontSize: 16))),
      ))),
      const Spacer(), Text('Correct answers: $score', textAlign: TextAlign.center, style: const TextStyle(color: _gold)),
    ]));
  }
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});
  @override
  State<MemoryGame> createState() => _MemoryGameState();
}
class _MemoryGameState extends State<MemoryGame> {
  final symbols = ['🍀','🚀','🎸','🐼','🍀','🚀','🎸','🐼'];
  late List<int> order;
  final opened = <int>[];
  final matched = <int>{};
  int moves = 0;
  @override
  void initState() { super.initState(); _shuffle(); }
  void _shuffle() { order = List.generate(8,(i)=>i)..shuffle(); opened.clear(); matched.clear(); moves=0; }
  void _tap(int i) {
    if (opened.length == 2 || opened.contains(i) || matched.contains(i)) return;
    setState(() { opened.add(i); if (opened.length == 2) { moves++; if (symbols[order[opened[0]]] == symbols[order[opened[1]]]) { matched.addAll(opened); opened.clear(); } else { Future.delayed(const Duration(milliseconds:750), () { if(mounted) setState(()=>opened.clear()); }); } } });
  }
  @override
  Widget build(BuildContext context) => _GameScaffold('Memory Match', Column(children: [
    Text('Moves: $moves  •  Pairs: ${matched.length ~/ 2}/4', style: const TextStyle(color: _gold, fontSize: 19)),
    const SizedBox(height: 20), Expanded(child: GridView.builder(itemCount:8, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:1.35, crossAxisSpacing:12, mainAxisSpacing:12),
      itemBuilder:(c,i)=>InkWell(onTap:()=>_tap(i), child:Container(decoration:BoxDecoration(color:matched.contains(i)?Colors.green.shade900:_panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:_gold.withValues(alpha:.25))),alignment:Alignment.center,child:Text(matched.contains(i)||opened.contains(i)?symbols[order[i]]:'?',style:const TextStyle(fontSize:34,fontWeight:FontWeight.bold)))))),
    if(matched.length==8) const Text('You matched every pair!',style:TextStyle(color:_gold)),
    const SizedBox(height:12), FilledButton(onPressed:()=>setState(_shuffle),child:const Text('Restart')),
  ]));
}

class NumberPuzzleGame extends StatefulWidget {
  const NumberPuzzleGame({super.key});
  @override
  State<NumberPuzzleGame> createState()=>_NumberPuzzleGameState();
}
class _NumberPuzzleGameState extends State<NumberPuzzleGame>{
  List<int> tiles=[1,2,3,4,5,6,7,8,0];
  int moves=0;
  void shuffle(){ tiles=[1,2,3,4,5,6,7,8,0]; for(var i=0;i<100;i++){ final blank=tiles.indexOf(0); final opts=[blank-3,blank+3, if(blank%3>0) blank-1, if(blank%3<2) blank+1].where((x)=>x>=0&&x<9).toList(); final target=opts[Random().nextInt(opts.length)]; tiles[blank]=tiles[target]; tiles[target]=0; } moves=0; }
  void tap(int i){ final b=tiles.indexOf(0); if((i-b).abs()==3 || (i~/3==b~/3 && (i-b).abs()==1)){ setState(() { tiles[b]=tiles[i]; tiles[i]=0; moves++; }); } }
  bool get solved=>tiles.join()== '123456780';
  @override
  Widget build(BuildContext context)=>_GameScaffold('Number Puzzle',Column(children:[
    Text('Moves: $moves',style:const TextStyle(color:_gold,fontSize:20)),const SizedBox(height:20),
    Expanded(child:GridView.builder(itemCount:9,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:8,mainAxisSpacing:8),itemBuilder:(c,i)=>InkWell(onTap:()=>tap(i),child:Container(decoration:BoxDecoration(color:tiles[i]==0?Colors.black26:_panel,borderRadius:BorderRadius.circular(15),border:Border.all(color:_gold.withValues(alpha:.2))),alignment:Alignment.center,child:Text(tiles[i]==0?'': '${tiles[i]}',style:const TextStyle(fontSize:30,fontWeight:FontWeight.bold)))))),
    if(solved) const Text('Puzzle solved!',style:TextStyle(color:_gold,fontSize:20)),const SizedBox(height:12),FilledButton(onPressed:()=>setState(shuffle),child:const Text('Shuffle')),
  ]));
}

class WordPuzzleGame extends StatefulWidget { const WordPuzzleGame({super.key}); @override State<WordPuzzleGame> createState()=>_WordPuzzleGameState(); }
class _WordPuzzleGameState extends State<WordPuzzleGame>{
  final words=[('ELPPA','APPLE'),('NIARB','BRAIN'),('GNIRAC','RACING'),('ZZULPE','PUZZLE'),('DOLG','GOLD')];
  int index=0,score=0; final answer=TextEditingController(); String message='';
  @override void dispose(){answer.dispose();super.dispose();}
  void check(){if(answer.text.trim().toUpperCase()==words[index].$2){score++;message='Correct!';}else{message='Not quite. Try again.';} setState((){});}
  void next(){setState((){index=(index+1)%words.length;answer.clear();message='';});}
  @override Widget build(BuildContext context)=>_GameScaffold('Word Puzzle',Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Text('Score: $score',style:const TextStyle(color:_gold,fontSize:20)),const SizedBox(height:30),
    const Text('Unscramble this word',textAlign:TextAlign.center,style:TextStyle(color:Colors.white70)),
    const SizedBox(height:16),Text(words[index].$1.split('').join('  '),textAlign:TextAlign.center,style:const TextStyle(fontSize:34,fontWeight:FontWeight.w900,letterSpacing:2)),
    const SizedBox(height:22),TextField(controller:answer,textCapitalization:TextCapitalization.characters,decoration:const InputDecoration(hintText:'Your answer',border:OutlineInputBorder())),
    const SizedBox(height:12),FilledButton(onPressed:check,child:const Text('Check Answer')),Text(message,textAlign:TextAlign.center,style:const TextStyle(color:_gold)),
    const Spacer(),OutlinedButton(onPressed:next,child:const Text('Next Word')),
  ]));
}

class RaceGame extends StatefulWidget {
  final String vehicle;
  const RaceGame({super.key,required this.vehicle});
  @override State<RaceGame> createState()=>_RaceGameState();
}
class _RaceGameState extends State<RaceGame>{
  int lane=1,score=0,coins=0; bool running=false,crashed=false; Timer? timer; final obstacles=<int>[];
  void start(){timer?.cancel();setState((){lane=1;score=0;coins=0;obstacles.clear();running=true;crashed=false;});timer=Timer.periodic(const Duration(milliseconds:650),(_){if(!mounted)return;setState((){for(var i=0;i<obstacles.length;i++){obstacles[i]-=3;}obstacles.removeWhere((x)=>x<0);if(Random().nextDouble()<.55)obstacles.add(12+Random().nextInt(3));score++;coins=score~/10;if(obstacles.any((x)=>x<=1 && (x%3)==lane)){running=false;crashed=true;timer?.cancel();}});});}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_GameScaffold('${widget.vehicle} Racing',Column(children:[
    Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[Text('Distance: $score',style:const TextStyle(color:_gold)),Text('Coins: $coins',style:const TextStyle(color:_gold))]),
    const SizedBox(height:16),Expanded(child:GestureDetector(onHorizontalDragEnd:(d)=>setState(()=>lane=(lane+((d.primaryVelocity??0)<0?-1:1)).clamp(0,2).toInt()),child:Container(decoration:BoxDecoration(color:const Color(0xFF202B3A),borderRadius:BorderRadius.circular(20)),child:CustomPaint(painter:_RoadPainter(lane,obstacles,widget.vehicle),child:const SizedBox.expand())))),
    const SizedBox(height:12),if(crashed) const Text('Crash! Tap race again.',style:TextStyle(color:Colors.orangeAccent)),
    FilledButton(onPressed:running?null:start,child:Text(running?'RACING...':'START RACE')),
    const Text('Swipe left or right to change lanes and avoid traffic.',style:TextStyle(color:Colors.white54,fontSize:12)),
  ]));
}
class _RoadPainter extends CustomPainter{
  final int lane; final List<int> obstacles; final String vehicle;
  _RoadPainter(this.lane,this.obstacles,this.vehicle);
  @override void paint(Canvas canvas,Size size){final p=Paint()..color=Colors.white24..strokeWidth=3;for(var x=1;x<3;x++){for(var y=0.0;y<size.height;y+=35){canvas.drawLine(Offset(size.width*x/3,y),Offset(size.width*x/3,y+18),p);}}final car=Paint()..color=_gold;final w=size.width/7,h=size.height/10;canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width*(lane+.5)/3-w/2,size.height-h-18,w,h),const Radius.circular(10)),car);final obs=Paint()..color=Colors.redAccent;for(final o in obstacles){final l=o%3;final y=size.height-(o*size.height/15);canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width*(l+.5)/3-w/2,y,w,h),const Radius.circular(8)),obs);}}
  @override bool shouldRepaint(covariant _RoadPainter old)=>true;
}
