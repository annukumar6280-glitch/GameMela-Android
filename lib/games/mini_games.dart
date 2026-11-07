import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/backend.dart';
import '../ads/banner_ad.dart';

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
  @override State<BubblePopGame> createState() => _BubblePopGameState();
}
class _BubblePopGameState extends State<BubblePopGame> {
  final _rng=Random();
  final _colors=const [Color(0xFF39C6F4),Color(0xFFFF5D8F),Color(0xFF9D7BFF),Color(0xFFFFC857),Color(0xFF58D68D)];
  List<int> bubbles=[];
  int score=0,seconds=45,combo=0,level=1;
  bool playing=false,finished=false,rewarded=false;
  Timer? timer;
  @override void initState(){super.initState();_reset();}
  void _reset(){
    timer?.cancel();
    setState((){score=0;seconds=45;combo=0;level=1;playing=true;finished=false;rewarded=false;bubbles=List.generate(30,(i)=>i);});
    timer=Timer.periodic(const Duration(seconds:1),(_){if(!mounted||!playing)return;setState(()=>seconds--);if(seconds<=0)_finish();});
  }
  void _pop(int id){
    if(!playing||!bubbles.contains(id))return;
    setState((){
      bubbles.remove(id);combo++;score+=10+min(combo,10)*2;level=1+score~/250;
      if(bubbles.isEmpty){bubbles=List.generate(30,(i)=>i);seconds=min(45,seconds+5);}
    });
  }
  void _finish(){
    if(!playing)return;
    timer?.cancel();setState((){playing=false;finished=true;});
    if(!rewarded&&score>=100){rewarded=true;GameMelaBackend.claimReward('bubble_pop',score);GameMelaBackend.saveProgress('bubble_pop',score);GameMelaAds.gameFinished();}
  }
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_GameScaffold('Bubble Pop',Column(children:[
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
      _bubbleHud('SCORE',score.toString()),_bubbleHud('TIME',seconds.toString()+'s'),_bubbleHud('COMBO','x'+combo.toString()),_bubbleHud('LEVEL',level.toString())]),
    const SizedBox(height:12),
    Expanded(child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF10264B),Color(0xFF251747)]),border:Border.all(color:Colors.cyanAccent.withValues(alpha:.3))),child:GridView.builder(
      itemCount:bubbles.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:5,crossAxisSpacing:9,mainAxisSpacing:9),
      itemBuilder:(c,i){final id=bubbles[i];final color=_colors[(id*7+level)%_colors.length];return GestureDetector(onTap:()=>_pop(id),child:DecoratedBox(decoration:BoxDecoration(shape:BoxShape.circle,gradient:RadialGradient(colors:[Colors.white.withValues(alpha:.9),color,color.withValues(alpha:.65)],stops:const[0,.18,1]),boxShadow:[BoxShadow(color:color.withValues(alpha:.5),blurRadius:13,spreadRadius:1)]),child:const Center(child:Icon(Icons.circle_outlined,color:Colors.white70,size:34))));},
    ))),
    const SizedBox(height:12),
    if(finished)Text('TIME UP  •  FINAL SCORE '+score.toString(),style:const TextStyle(color:_gold,fontWeight:FontWeight.w900,fontSize:17)),
    Row(children:[Expanded(child:Text(playing?'Tap bubbles fast. Build a combo to score more!':'Round complete — play another round',style:const TextStyle(color:Colors.white60,fontSize:12))),FilledButton.icon(onPressed:_reset,icon:const Icon(Icons.replay),label:const Text('PLAY'))]),
  ]));
}
Widget _bubbleHud(String label,String value)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:9),decoration:BoxDecoration(color:_panel,borderRadius:BorderRadius.circular(13),border:Border.all(color:Colors.white12)),child:Column(children:[Text(label,style:const TextStyle(color:Colors.white54,fontSize:9,fontWeight:FontWeight.bold)),Text(value,style:const TextStyle(color:_gold,fontSize:16,fontWeight:FontWeight.w900))]));

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
  bool rewarded = false;
  void answer(int choice) {
    setState(() { if (choice == questions[index].$3) score++; index++; if (index == questions.length) finished = true; });
    if (finished && !rewarded) {
      rewarded = true;
      GameMelaBackend.claimReward('quiz', score);
      GameMelaBackend.saveProgress('quiz', score);
      GameMelaAds.gameFinished();
    }
  }
  @override
  Widget build(BuildContext context) {
    if (finished) { return _GameScaffold('Quiz Challenge', Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.emoji_events, color: _gold, size: 64), const SizedBox(height: 12),
      Text('Your score: $score / ${questions.length}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18), FilledButton(onPressed: () => setState(() { index=0; score=0; finished=false; rewarded=false; }), child: const Text('Try Again')),
    ]))); }
    final q = questions[index];
    return _GameScaffold('Quiz Challenge', Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('QUESTION ${index+1} OF ${questions.length}', style: const TextStyle(color: _gold, letterSpacing: 2)),
      const SizedBox(height: 18), Text(q.$1, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: FilledButton.tonal(
        onPressed: () => answer(i),
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
  bool rewarded = false;
  @override
  void initState() { super.initState(); _shuffle(); }
  void _shuffle() { order = List.generate(8,(i)=>i)..shuffle(); opened.clear(); matched.clear(); moves=0; rewarded=false; }
  void _tap(int i) {
    if (opened.length == 2 || opened.contains(i) || matched.contains(i)) return;
    setState(() { opened.add(i); if (opened.length == 2) { moves++; if (symbols[order[opened[0]]] == symbols[order[opened[1]]]) { matched.addAll(opened); opened.clear(); } else { Future.delayed(const Duration(milliseconds:750), () { if(mounted) setState(()=>opened.clear()); }); } } });
    if (matched.length == 8 && !rewarded) { rewarded=true; GameMelaBackend.claimReward('memory',40); GameMelaBackend.saveProgress('memory',moves);GameMelaAds.gameFinished(); }
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
  bool rewarded=false;
  void shuffle(){ tiles=[1,2,3,4,5,6,7,8,0]; for(var i=0;i<100;i++){ final blank=tiles.indexOf(0); final opts=[blank-3,blank+3, if(blank%3>0) blank-1, if(blank%3<2) blank+1].where((x)=>x>=0&&x<9).toList(); final target=opts[Random().nextInt(opts.length)]; tiles[blank]=tiles[target]; tiles[target]=0; } moves=0; rewarded=false; }
  void tap(int i){ final b=tiles.indexOf(0); if((i-b).abs()==3 || (i~/3==b~/3 && (i-b).abs()==1)){ setState(() { tiles[b]=tiles[i]; tiles[i]=0; moves++; }); if(solved && !rewarded){rewarded=true;GameMelaBackend.claimReward('number_puzzle',100);GameMelaBackend.saveProgress('number_puzzle',moves);GameMelaAds.gameFinished();} } }
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
  int index=0,score=0; final answer=TextEditingController(); String message=''; bool rewarded=false;
  @override void dispose(){answer.dispose();super.dispose();}
  void check(){if(answer.text.trim().toUpperCase()==words[index].$2){score++;message='Correct!';if(score>=5&&!rewarded){rewarded=true;GameMelaBackend.claimReward('word_puzzle',50);GameMelaBackend.saveProgress('word_puzzle',score);GameMelaAds.gameFinished();}}else{message='Not quite. Try again.';} setState((){});}
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
  final _rng=Random();final List<_Traffic> traffic=[];
  Timer? timer;int lane=1,score=0,best=0,level=1;double roadShift=0;
  bool running=false,crashed=false,paused=false,nitro=false;int nitroTicks=0;
  static const _colors=[Color(0xFFFF5353),Color(0xFF38C8F2),Color(0xFFAA83FF),Color(0xFFFFB347),Color(0xFFECEFF4)];
  void start(){
    timer?.cancel();setState((){lane=1;score=0;level=1;roadShift=0;traffic.clear();running=true;crashed=false;paused=false;nitro=false;nitroTicks=0;});
    timer=Timer.periodic(const Duration(milliseconds:45),(_)=>_tick());
  }
  void _tick(){
    if(!mounted||!running||paused)return;
    setState((){
      final speed=(nitro?8.0:4.0)+level*.35;roadShift=(roadShift+speed*2)%64;
      for(final t in traffic){t.y+=speed/500;}traffic.removeWhere((t)=>t.y>1.15);
      if(_rng.nextDouble()<.025+level*.002&&traffic.length<4){final free=[0,1,2].where((l)=>!traffic.any((t)=>t.lane==l&&t.y<.25)).toList();if(free.isNotEmpty)traffic.add(_Traffic(free[_rng.nextInt(free.length)],-.16,_colors[_rng.nextInt(_colors.length)]));}
      if(nitroTicks>0){nitroTicks--;if(nitroTicks==0)nitro=false;}
      if(traffic.any((t)=>t.lane==lane&&t.y>.70&&t.y<.90)){
        running=false;crashed=true;timer?.cancel();
        if(score>=20){final key=widget.vehicle.toLowerCase()=='bike'?'bike_race':'car_race';GameMelaBackend.claimReward(key,score);GameMelaBackend.saveProgress(key,score);GameMelaAds.gameFinished();}
      }else{score++;level=1+score~/250;if(score>best)best=score;}
    });
  }
  void move(int d){if(running&&!paused)setState(()=>lane=(lane+d).clamp(0,2));}
  void boost(){if(running&&!paused&&nitroTicks==0)setState(() { nitro=true;nitroTicks=65; });}
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>_GameScaffold(widget.vehicle+' Racing',Column(children:[
    Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
      _raceStat('DISTANCE',score.toString()+'m'),_raceStat('LEVEL',level.toString()),_raceStat('BEST',best.toString()+'m'),
      IconButton.filledTonal(onPressed:running?()=>setState(()=>paused=!paused):null,icon:Icon(paused?Icons.play_arrow:Icons.pause))]),
    const SizedBox(height:10),
    Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(22),child:Stack(fit:StackFit.expand,children:[
      CustomPaint(painter:_ProRoadPainter(lane,traffic,roadShift,widget.vehicle.toLowerCase()=='bike',nitro)),
      if(nitro)const Positioned(top:12,right:12,child:Text('⚡ NITRO',style:TextStyle(color:Colors.cyanAccent,fontWeight:FontWeight.w900))),
      if(!running)Container(color:Colors.black.withValues(alpha:.66),child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
        Icon(crashed?Icons.car_crash:Icons.flag_circle,color:_gold,size:58),const SizedBox(height:8),
        Text(crashed?'RACE OVER':'READY TO RACE',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),
        Text(crashed?'Distance '+score.toString()+' m  •  Best '+best.toString()+' m':'Dodge traffic and beat your best distance',style:const TextStyle(color:Colors.white70)),
        const SizedBox(height:16),FilledButton.icon(onPressed:start,icon:const Icon(Icons.play_arrow),label:Text(crashed?'RACE AGAIN':'START RACE'),style:FilledButton.styleFrom(backgroundColor:_gold,foregroundColor:Colors.black,padding:const EdgeInsets.symmetric(horizontal:25,vertical:13))),
      ]))),
      if(paused)Container(color:Colors.black54,child:Center(child:FilledButton.icon(onPressed:()=>setState(()=>paused=false),icon:const Icon(Icons.play_arrow),label:const Text('RESUME')))),
    ]))),
    const SizedBox(height:12),
    Row(children:[Expanded(child:_raceControl(Icons.chevron_left,'LEFT',()=>move(-1))),const SizedBox(width:9),Expanded(child:_raceControl(Icons.chevron_right,'RIGHT',()=>move(1))),const SizedBox(width:9),Expanded(child:_raceControl(Icons.bolt,'NITRO',boost,true))]),
    const SizedBox(height:6),const Text('Change lanes to dodge traffic • Tap NITRO for a speed burst',style:TextStyle(color:Colors.white54,fontSize:11)),
  ]));
}
class _Traffic{int lane;double y;final Color color;_Traffic(this.lane,this.y,this.color);}
Widget _raceStat(String label,String value)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),decoration:BoxDecoration(color:_panel,borderRadius:BorderRadius.circular(12)),child:Column(children:[Text(label,style:const TextStyle(color:Colors.white54,fontSize:9)),Text(value,style:const TextStyle(color:_gold,fontWeight:FontWeight.w900))]));
Widget _raceControl(IconData icon,String label,VoidCallback tap,[bool accent=false])=>Material(color:accent?const Color(0xFF12475A):_panel,borderRadius:BorderRadius.circular(14),child:InkWell(onTap:tap,borderRadius:BorderRadius.circular(14),child:Padding(padding:const EdgeInsets.symmetric(vertical:10),child:Column(children:[Icon(icon,color:accent?Colors.cyanAccent:Colors.white,size:24),Text(label,style:TextStyle(fontSize:10,color:accent?Colors.cyanAccent:Colors.white70,fontWeight:FontWeight.bold))]))));
class _ProRoadPainter extends CustomPainter{
  final int lane;final List<_Traffic> traffic;final double shift;final bool bike,nitro;
  _ProRoadPainter(this.lane,this.traffic,this.shift,this.bike,this.nitro);
  @override void paint(Canvas canvas,Size size){
    final w=size.width,h=size.height,rect=Offset.zero&size;
    canvas.drawRect(rect,Paint()..shader=const LinearGradient(colors:[Color(0xFF174D3D),Color(0xFF071D25)],begin:Alignment.topCenter,end:Alignment.bottomCenter).createShader(rect));
    final road=Path()..moveTo(w*.18,0)..lineTo(w*.82,0)..lineTo(w*.99,h)..lineTo(w*.01,h)..close();
    canvas.drawPath(road,Paint()..shader=const LinearGradient(colors:[Color(0xFF505967),Color(0xFF202936)],begin:Alignment.topCenter,end:Alignment.bottomCenter).createShader(rect));
    final edge=Paint()..color=const Color(0xFFFFD166)..strokeWidth=3;
    canvas.drawLine(Offset(w*.18,0),Offset(w*.01,h),edge);canvas.drawLine(Offset(w*.82,0),Offset(w*.99,h),edge);
    for(int l=1;l<=2;l++){for(int i=-1;i<12;i++){final y=i*62.0+shift;final p=.7+(y/h).clamp(0.0,1.0)*.6;canvas.drawLine(Offset(w*(.18+l*.213),y),Offset(w*(.18+l*.213),y+28*p),Paint()..color=Colors.white70..strokeWidth=2*p);}}
    for(int i=0;i<8;i++){final y=((i*93.0+shift*1.6)%(h+40))-20;canvas.drawCircle(Offset(w*.09,y),2.5,Paint()..color=Colors.cyanAccent.withValues(alpha:.5));canvas.drawCircle(Offset(w*.91,y),2.5,Paint()..color=Colors.cyanAccent.withValues(alpha:.5));}
    for(final t in traffic){final x=w*(.286+t.lane*.214);_vehicle(canvas,Offset(x,h*t.y),w*.135,h*.12,t.color,false);}
    _vehicle(canvas,Offset(w*(.286+lane*.214),h*.82),w*.15,h*.145,nitro?Colors.cyanAccent:_gold,true,bike:bike);
  }
  void _vehicle(Canvas c,Offset p,double w,double h,Color color,bool player,{bool bike=false}){
    final dark=Paint()..color=const Color(0xFF101722),body=Paint()..color=color,glass=Paint()..color=const Color(0xFFB8F1FF);
    if(bike){
      c.drawCircle(Offset(p.dx,p.dy-h*.32),w*.17,dark);c.drawCircle(Offset(p.dx,p.dy+h*.30),w*.17,dark);
      final frame=Paint()..color=color..strokeWidth=w*.12..strokeCap=StrokeCap.round;
      c.drawLine(Offset(p.dx,p.dy-h*.28),Offset(p.dx-w*.2,p.dy+h*.13),frame);c.drawLine(Offset(p.dx,p.dy-h*.28),Offset(p.dx+w*.2,p.dy+h*.13),frame);c.drawLine(Offset(p.dx-w*.2,p.dy+h*.13),Offset(p.dx+w*.2,p.dy+h*.13),frame);
      c.drawCircle(Offset(p.dx,p.dy-h*.08),w*.13,body);c.drawCircle(Offset(p.dx,p.dy-h*.34),w*.07,glass);return;
    }
    final bodyRect=Rect.fromCenter(center:p,width:w*.78,height:h*.9);
    if(player)c.drawOval(Rect.fromCenter(center:Offset(p.dx,p.dy+h*.5),width:w*1.15,height:h*.2),Paint()..color=_gold.withValues(alpha:.5)..maskFilter=const MaskFilter.blur(BlurStyle.normal,8));
    c.drawRRect(RRect.fromRectAndRadius(bodyRect,Radius.circular(w*.2)),body);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(p.dx,p.dy-h*.2),width:w*.57,height:h*.24),Radius.circular(w*.1)),glass);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(p.dx,p.dy+h*.18),width:w*.57,height:h*.2),Radius.circular(w*.08)),dark);
    for(final side in [-1.0,1.0]){for(final yy in [-.25,.25]){c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(p.dx+side*w*.4,p.dy+yy*h),width:w*.14,height:h*.22),const Radius.circular(3)),dark);}}
    final lamp=Paint()..color=Colors.white;
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(p.dx-w*.23,p.dy-h*.4),width:w*.18,height:h*.06),const Radius.circular(2)),lamp);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(p.dx+w*.23,p.dy-h*.4),width:w*.18,height:h*.06),const Radius.circular(2)),lamp);
  }
  @override bool shouldRepaint(covariant _ProRoadPainter old)=>true;
}

