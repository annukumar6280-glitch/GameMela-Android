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
    case 'Color Sort': return const ColorSortGame();
    case 'Stack Rush': return const StackRushGame();
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

class QuizGame extends StatefulWidget { const QuizGame({super.key}); @override State<QuizGame> createState()=>_QuizGameState(); }
class _QuizGameState extends State<QuizGame>{
 static const bank=[
 ('Which planet is called the Red Planet?',['Venus','Mars','Jupiter','Mercury'],1),('How many sides has a hexagon?',['5','6','7','8'],1),('Largest mammal on Earth?',['Elephant','Blue whale','Giraffe','Shark'],1),('What is 12 x 8?',['86','92','96','108'],2),('Plants absorb which gas?',['Oxygen','Nitrogen','Carbon dioxide','Hydrogen'],2),
 ('Fastest land animal?',['Lion','Cheetah','Horse','Tiger'],1),('How many continents?',['5','6','7','8'],2),('Capital of Japan?',['Seoul','Beijing','Tokyo','Bangkok'],2),('Largest ocean?',['Atlantic','Indian','Arctic','Pacific'],3),('How many rainbow colours?',['5','6','7','8'],2),
 ('Which organ pumps blood?',['Lungs','Heart','Brain','Kidney'],1),('15 squared?',['125','200','225','250'],2),('Liquid metal at room temperature?',['Iron','Mercury','Copper','Gold'],1),('Who wrote Romeo and Juliet?',['Dickens','Shakespeare','Austen','Tolkien'],1),('Nearest star to Earth?',['Sirius','Sun','Polaris','Vega'],1),
 ('Players in a football team on field?',['9','10','11','12'],2),('Chemical formula of water?',['CO2','O2','H2O','NaCl'],2),('Ship of the desert?',['Horse','Camel','Donkey','Yak'],1),('144 divided by 12?',['10','11','12','14'],2),('Pyramids of Giza are in?',['Greece','Egypt','Mexico','India'],1)
 ];
 late List<(String,List<String>,int)> round; int index=0,score=0,streak=0,bestStreak=0; int? selected; bool answered=false,finished=false;
 @override void initState(){super.initState();_newRound();}
 void _newRound(){final pool=[...bank]..shuffle();setState((){round=pool.take(10).toList();index=0;score=0;streak=0;bestStreak=0;selected=null;answered=false;finished=false;});}
 void _answer(int choice){if(answered||finished)return;final correct=round[index].$3;setState((){selected=choice;answered=true;if(choice==correct){streak++;score+=10+(streak>=3?5:0);}else{streak=0;}if(streak>bestStreak)bestStreak=streak;});}
 void _next(){if(index==round.length-1){setState(()=>finished=true);GameMelaBackend.claimReward('quiz',score);GameMelaBackend.saveProgress('quiz',score);GameMelaAds.gameFinished();}else{setState((){index++;selected=null;answered=false;});}}
 @override Widget build(BuildContext context){if(finished)return _GameScaffold('Quiz Challenge',Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.emoji_events_rounded,color:_gold,size:70),const SizedBox(height:12),const Text('ROUND COMPLETE',style:TextStyle(fontSize:23,fontWeight:FontWeight.w900)),Text(score.toString()+' / 100 points',style:const TextStyle(color:_gold,fontSize:25,fontWeight:FontWeight.w900)),Text('Best streak: '+bestStreak.toString(),style:const TextStyle(color:Colors.white60)),const SizedBox(height:20),FilledButton.icon(onPressed:_newRound,icon:const Icon(Icons.replay),label:const Text('PLAY AGAIN'))])));
 final q=round[index];return _GameScaffold('Quiz Challenge',Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('QUESTION '+(index+1).toString()+'/10',style:const TextStyle(color:_gold,fontWeight:FontWeight.w900)),Text('SCORE '+score.toString(),style:const TextStyle(color:_gold,fontWeight:FontWeight.bold))]),const SizedBox(height:9),LinearProgressIndicator(value:(index+1)/10,minHeight:6,color:_gold,backgroundColor:Colors.white12),const SizedBox(height:24),Text(q.$1,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w800)),const SizedBox(height:20),...List.generate(4,(i){final correct=i==q.$3;final chosen=i==selected;return Padding(padding:const EdgeInsets.only(bottom:10),child:OutlinedButton(style:OutlinedButton.styleFrom(backgroundColor:answered&&correct?Colors.green.withValues(alpha:.25):answered&&chosen?Colors.red.withValues(alpha:.2):_panel,padding:const EdgeInsets.symmetric(vertical:15,horizontal:12),alignment:Alignment.centerLeft),onPressed:answered?null:()=>_answer(i),child:Text(String.fromCharCode(65+i)+'.  '+q.$2[i],style:const TextStyle(fontSize:16,color:Colors.white))));}),const Spacer(),if(answered)Text(selected==q.$3?'Correct! Great job.':'Correct answer: '+q.$2[q.$3],style:TextStyle(color:selected==q.$3?Colors.greenAccent:Colors.orangeAccent,fontWeight:FontWeight.bold)),const SizedBox(height:10),FilledButton(onPressed:answered?_next:null,child:Text(index==9?'FINISH ROUND':'NEXT QUESTION'))]));}
}
class MemoryGame extends StatefulWidget { const MemoryGame({super.key}); @override State<MemoryGame> createState()=>_MemoryGameState(); }
class _MemoryGameState extends State<MemoryGame>{
 static const symbols=['🍀','🚀','🎸','🐼','🍉','🦊','⚽','🌈']; late List<int> order;final opened=<int>[];final matched=<int>{};int moves=0;bool locked=false,rewarded=false;
 @override void initState(){super.initState();_shuffle();}
 void _shuffle(){order=[...List.generate(8,(i)=>i),...List.generate(8,(i)=>i)]..shuffle();opened.clear();matched.clear();moves=0;locked=false;rewarded=false;}
 void _tap(int i){if(locked||opened.contains(i)||matched.contains(i))return;setState(()=>opened.add(i));if(opened.length==2){moves++;final a=opened[0],b=opened[1];if(order[a]==order[b]){setState(() { matched.add(a); matched.add(b); opened.clear(); });if(matched.length==16&&!rewarded){rewarded=true;GameMelaBackend.claimReward('memory',80);GameMelaBackend.saveProgress('memory',moves);GameMelaAds.gameFinished();}}else{locked=true;Future.delayed(const Duration(milliseconds:750),(){if(mounted)setState(() { opened.clear(); locked=false; });});}}}
 @override Widget build(BuildContext context)=>_GameScaffold('Memory Match',Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('MOVES  '+moves.toString(),style:const TextStyle(color:_gold,fontWeight:FontWeight.w900)),Text('PAIRS  '+(matched.length~/2).toString()+'/8',style:const TextStyle(color:_gold,fontWeight:FontWeight.w900))]),const SizedBox(height:12),LinearProgressIndicator(value:matched.length/16,minHeight:6,color:_gold,backgroundColor:Colors.white12),const SizedBox(height:14),Expanded(child:GridView.builder(itemCount:16,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,crossAxisSpacing:9,mainAxisSpacing:9,childAspectRatio:.9),itemBuilder:(c,i){final face=matched.contains(i)||opened.contains(i);return InkWell(onTap:()=>_tap(i),borderRadius:BorderRadius.circular(14),child:AnimatedContainer(duration:const Duration(milliseconds:180),decoration:BoxDecoration(gradient:face?const LinearGradient(colors:[Color(0xFF344E78),Color(0xFF1B3152)]):const LinearGradient(colors:[Color(0xFF263D60),Color(0xFF111D32)]),borderRadius:BorderRadius.circular(14),border:Border.all(color:matched.contains(i)?Colors.greenAccent:_gold.withValues(alpha:.3))),alignment:Alignment.center,child:Text(face?symbols[order[i]]:'?',style:TextStyle(fontSize:face?29:32,fontWeight:FontWeight.w900,color:face?Colors.white:_gold))));})),if(matched.length==16)const Text('PERFECT MATCH! 🎉',style:TextStyle(color:_gold,fontWeight:FontWeight.w900,fontSize:18)),const SizedBox(height:8),FilledButton.icon(onPressed:()=>setState(_shuffle),icon:const Icon(Icons.shuffle),label:const Text('NEW GAME'))]));
}
class NumberPuzzleGame extends StatefulWidget { const NumberPuzzleGame({super.key}); @override State<NumberPuzzleGame> createState()=>_NumberPuzzleGameState(); }
class _NumberPuzzleGameState extends State<NumberPuzzleGame>{
 List<int> tiles=[1,2,3,4,5,6,7,8,0];int moves=0,seconds=0;bool rewarded=false,won=false;Timer? timer;
 @override void initState(){super.initState();_shuffle();}
 void _shuffle(){timer?.cancel();tiles=[1,2,3,4,5,6,7,8,0];for(var n=0;n<180;n++){final b=tiles.indexOf(0);final opts=[if(b>=3)b-3,if(b<6)b+3,if(b%3>0)b-1,if(b%3<2)b+1];final t=opts[Random().nextInt(opts.length)];tiles[b]=tiles[t];tiles[t]=0;}moves=0;seconds=0;rewarded=false;won=false;timer=Timer.periodic(const Duration(seconds:1),(_){if(mounted&&!won)setState(()=>seconds++);});}
 void _tap(int i){if(won)return;final b=tiles.indexOf(0);if((i-b).abs()==3||(i~/3==b~/3&&(i-b).abs()==1)){setState(() { tiles[b]=tiles[i]; tiles[i]=0; moves++; });if(solved){won=true;timer?.cancel();if(!rewarded){rewarded=true;GameMelaBackend.claimReward('number_puzzle',100);GameMelaBackend.saveProgress('number_puzzle',moves);GameMelaAds.gameFinished();}}}}
 bool get solved=>tiles.join()=='123456780';
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>_GameScaffold('Number Puzzle',Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[_bubbleHud('MOVES',moves.toString()),_bubbleHud('TIME',seconds.toString()+'s'),_bubbleHud('STATUS',won?'WON':'PLAY')]),const SizedBox(height:16),Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:GridView.builder(physics:const NeverScrollableScrollPhysics(),itemCount:9,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:9,mainAxisSpacing:9),itemBuilder:(c,i)=>InkWell(onTap:()=>_tap(i),borderRadius:BorderRadius.circular(16),child:AnimatedContainer(duration:const Duration(milliseconds:130),decoration:BoxDecoration(gradient:tiles[i]==0?null:const LinearGradient(colors:[Color(0xFF315C83),Color(0xFF172B49)]),color:tiles[i]==0?Colors.black26:null,borderRadius:BorderRadius.circular(16),border:Border.all(color:_gold.withValues(alpha:.25))),alignment:Alignment.center,child:Text(tiles[i]==0?'':tiles[i].toString(),style:const TextStyle(fontSize:34,fontWeight:FontWeight.w900)))))))),if(won)const Text('PUZZLE SOLVED! 🏆',style:TextStyle(color:_gold,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:12),FilledButton.icon(onPressed:()=>setState(_shuffle),icon:const Icon(Icons.refresh),label:const Text('NEW PUZZLE'))]));
}
class WordPuzzleGame extends StatefulWidget { const WordPuzzleGame({super.key}); @override State<WordPuzzleGame> createState()=>_WordPuzzleGameState(); }
class _WordPuzzleGameState extends State<WordPuzzleGame>{
 static const words=[('ELPPA','APPLE'),('NIARB','BRAIN'),('GNICAR','RACING'),('ELZZUP','PUZZLE'),('DLOG','GOLD'),('RETAW','WATER'),('NOOM','MOON'),('REWOLF','FLOWER'),('RETUPMOC','COMPUTER'),('THGIL','LIGHT'),('REWOP','POWER'),('KOOB','BOOK'),('RIAH','HAIR'),('HSALF','FLASH'),('ENOTS','STONE')];
 int index=0,score=0,streak=0;final answer=TextEditingController();String message='';bool solved=false;
 @override void dispose(){answer.dispose();super.dispose();}
 void check(){if(solved)return;final ok=answer.text.trim().toUpperCase()==words[index].$2;setState(() { message=ok?'Correct! +10 points':'Try again — look carefully'; solved=ok; if(ok){score+=10;streak++;}else{streak=0;} });}
 void next(){if(index==words.length-1){GameMelaBackend.claimReward('word_puzzle',score);GameMelaBackend.saveProgress('word_puzzle',score);GameMelaAds.gameFinished();}setState(() { index=(index+1)%words.length; answer.clear(); message=''; solved=false; });}
 @override Widget build(BuildContext context)=>_GameScaffold('Word Puzzle',Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('SCORE  '+score.toString(),style:const TextStyle(color:_gold,fontWeight:FontWeight.w900)),Text('WORD '+(index+1).toString()+'/'+words.length.toString(),style:const TextStyle(color:Colors.white60))]),const SizedBox(height:26),const Text('UNSCRAMBLE THE WORD',textAlign:TextAlign.center,style:TextStyle(color:Colors.white60,letterSpacing:1.4)),const SizedBox(height:20),Container(padding:const EdgeInsets.symmetric(vertical:28),decoration:BoxDecoration(color:_panel,borderRadius:BorderRadius.circular(20),border:Border.all(color:_gold.withValues(alpha:.25))),child:Text(words[index].$1.split('').join('  '),textAlign:TextAlign.center,style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900,letterSpacing:2,color:_gold))),const SizedBox(height:20),TextField(controller:answer,textCapitalization:TextCapitalization.characters,enabled:!solved,onSubmitted:(_)=>check(),decoration:const InputDecoration(hintText:'Type your answer',border:OutlineInputBorder(),prefixIcon:Icon(Icons.edit))),const SizedBox(height:12),FilledButton(onPressed:solved?next:check,child:Text(solved?'NEXT WORD':'CHECK ANSWER')),const SizedBox(height:10),Text(message,textAlign:TextAlign.center,style:TextStyle(color:solved?Colors.greenAccent:Colors.orangeAccent,fontWeight:FontWeight.bold)),const Spacer(),Text('Streak  x'+streak.toString()+'   •   10 points per word',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white54))]));
}
class ColorSortGame extends StatefulWidget{const ColorSortGame({super.key});@override State<ColorSortGame> createState()=>_ColorSortGameState();}
class _ColorSortGameState extends State<ColorSortGame>{
 static const colors=[Color(0xFFFF5D8F),Color(0xFF43C6F5),Color(0xFFFFC857),Color(0xFF9B7BFF)];
 late List<List<int>> tubes;int moves=0;bool won=false;
 @override void initState(){super.initState();_reset();}
 void _reset(){final balls=<int>[];for(var c=0;c<4;c++){for(var i=0;i<3;i++){balls.add(c);}}balls.shuffle();tubes=List.generate(6,(i)=>i<4?[]:[]);var k=0;for(var i=0;i<4;i++){for(var j=0;j<3;j++){tubes[i].add(balls[k++]);}}moves=0;won=false;}
 void _tap(int i){if(won)return;setState(() { if(selected==null){if(tubes[i].isNotEmpty)selected=i;}else if(selected==i){selected=null;}else{final from=tubes[selected!],to=tubes[i];if(from.isNotEmpty&&to.length<3&&(to.isEmpty||to.last==from.last)){to.add(from.removeLast());moves++;}selected=null;if(tubes.where((t)=>t.isNotEmpty&&t.length==3&&t.every((x)=>x==t.first)).length==4){won=true;GameMelaBackend.claimReward('color_sort',moves);GameMelaBackend.saveProgress('color_sort',moves);GameMelaAds.gameFinished();}} });}
 int? selected;
 @override Widget build(BuildContext context)=>_GameScaffold('Color Sort',Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[_bubbleHud('MOVES',moves.toString()),_bubbleHud('TUBES','6'),_bubbleHud('STATUS',won?'WON':'PLAY')]),const SizedBox(height:18),const Text('Sort each colour into its own tube',style:TextStyle(color:Colors.white60)),const SizedBox(height:20),Expanded(child:GridView.count(crossAxisCount:3,mainAxisSpacing:20,crossAxisSpacing:14,childAspectRatio:.72,children:List.generate(6,(i)=>GestureDetector(onTap:()=>_tap(i),child:AnimatedContainer(duration:const Duration(milliseconds:160),padding:const EdgeInsets.all(7),decoration:BoxDecoration(color:selected==i?Colors.white12:_panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:selected==i?_gold:Colors.white24,width:selected==i?2:1)),child:Column(mainAxisAlignment:MainAxisAlignment.end,children:List.generate(3,(j){final tube=tubes[i];final ix=2-j;return Expanded(child:Container(width:38,margin:const EdgeInsets.symmetric(vertical:2),decoration:BoxDecoration(color:ix<tube.length?colors[tube[ix]]:Colors.white.withValues(alpha:.04),borderRadius:BorderRadius.circular(8),border:Border.all(color:Colors.white12))));}))))))),if(won)const Text('ALL COLOURS SORTED! 🎉',style:TextStyle(color:_gold,fontWeight:FontWeight.w900,fontSize:18)),const SizedBox(height:10),FilledButton.icon(onPressed:()=>setState(_reset),icon:const Icon(Icons.refresh),label:const Text('NEW PUZZLE'))]));
}
class StackRushGame extends StatefulWidget{const StackRushGame({super.key});@override State<StackRushGame> createState()=>_StackRushGameState();}
class _StackRushGameState extends State<StackRushGame> with SingleTickerProviderStateMixin{
 late final AnimationController controller;double x=0.0,direction=1.0,width=1.0;int score=0;bool playing=false,over=false;final List<double> blocks=[1.0];
 @override void initState(){super.initState();controller=AnimationController(vsync:this,duration:const Duration(milliseconds:1600))..addListener(()=>setState(()=>x=controller.value*2-1));}
 void start(){setState(() { score=0;width=1.0;blocks..clear()..add(1.0);playing=true;over=false; });controller.repeat(reverse:true,period:const Duration(milliseconds:1050));}
 void drop(){if(!playing)return;final offset=(x*.5).abs();final next=width-offset*.34;if(next<.12){controller.stop();setState(() { playing=false;over=true; });if(score>0){GameMelaBackend.claimReward('stack_rush',score);GameMelaBackend.saveProgress('stack_rush',score);GameMelaAds.gameFinished();}return;}setState(() { width=next;blocks.add(width);score++; });}
 @override void dispose(){controller.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>_GameScaffold('Stack Rush',Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[_bubbleHud('STACKS',score.toString()),_bubbleHud('WIDTH',(width*100).round().toString()+'%')]),const SizedBox(height:12),Expanded(child:GestureDetector(onTap:drop,behavior:HitTestBehavior.opaque,child:Container(width:double.infinity,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFF142B4D),Color(0xFF081322)])),child:Stack(alignment:Alignment.bottomCenter,children:[for(var i=0;i<blocks.length;i++)Positioned(bottom:i*25.0,child:Container(width:MediaQuery.sizeOf(context).width*.78*blocks[i],height:24,decoration:BoxDecoration(gradient:LinearGradient(colors:[Color.lerp(_cyan,_gold,i/20)!,Color.lerp(_gold,_cyan,i/20)!]),borderRadius:BorderRadius.circular(5),border:Border.all(color:Colors.white70.withValues(alpha:.5))))),if(!playing)Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(over?Icons.emoji_events:Icons.touch_app,color:_gold,size:55),const SizedBox(height:10),Text(over?'TOWER COLLAPSED':'TAP TO STACK',style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900)),Text('Score: '+score.toString(),style:const TextStyle(color:Colors.white70)),const SizedBox(height:14),FilledButton(onPressed:start,child:Text(over?'TRY AGAIN':'START'))]))])))),const SizedBox(height:10),const Text('Tap when the moving block lines up with your tower.',style:TextStyle(color:Colors.white54,fontSize:12))]));
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

