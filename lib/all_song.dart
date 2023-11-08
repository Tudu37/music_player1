import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class AllSongsPage extends StatefulWidget {
  const AllSongsPage({Key? key}) : super(key: key);

  @override
  State<AllSongsPage> createState() => _AllSongsPageState();
}

class _AllSongsPageState extends State<AllSongsPage> {

  final _audioQuery = OnAudioQuery();
  AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> songs = [];
  String currentsongTitle = '';
  String currentsongsubTitle = '';
  int currentIndex = 0;
  bool isPlaying = false;
  late Uri currenturi;


  bool isPlayerVisible = false;

  Stream<DurationState> get _durationStateStream => Rx.combineLatest2<Duration,Duration?,DurationState>(
    _audioPlayer.positionStream,_audioPlayer.durationStream,(position,duration)=>
      DurationState(position: position, total: duration??Duration.zero)
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // requestStoragePermission();
    // permissonHandler();
    grantPermission();
    _audioPlayer.currentIndexStream.listen((index) {
      if(index!=null){
        _updateCurrentPlayingSongDetail(index);
      }
    });

  }

  grantPermission()async {
    // await _audioQuery.permissionsRequest();
    await  Permission.storage.request();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return isPlayerVisible?
    Scaffold(
      backgroundColor: Colors.cyanAccent,
      appBar: AppBar(
        leading: Container(
          height: 5,
          decoration: BoxDecoration(
            color: Colors.greenAccent
          ),
          child: BackButton(
            onPressed:(){
              setState(() {
                isPlayerVisible = false;
              });
          } ,
            color: Colors.blue,
          ),
        ),
        backgroundColor:Colors.transparent,
        elevation: 0,
        title: Text("Music Player", style: TextStyle(color: Colors.black38),),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(height: height*0.13,),
            Container(
              height: height*0.55,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:Alignment.bottomCenter ,
                    end: Alignment.center,
                    colors: [
                      Colors.black,
                      Colors.black38.withOpacity(0.7),
                      Colors.black38.withOpacity(0.5),
                      Colors.black38.withOpacity(0.2),
                    ]
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                  child: Container(
                    height: height*0.38,
                    width: width*0.75,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14)
                    ),
                    child:
                    songs[currentIndex].id>=5000  ?
                    ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.asset("assets/music.jpg",fit: BoxFit.cover,))
                        :QueryArtworkWidget(
                      id:songs[currentIndex].id,
                      type: ArtworkType.AUDIO,

                    ) ,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Container(
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height*0.04,),
                    Center(child: Text("${currentsongTitle}",style: TextStyle(color: Colors.white,fontSize: 20),overflow: TextOverflow.ellipsis,)),
                    Text("${currentsongsubTitle}",style: TextStyle(color: Colors.white),overflow: TextOverflow.ellipsis,),
                    Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15,top: 14),
                      child: Container(
                        child: StreamBuilder<DurationState>(
                          stream:_durationStateStream ,
                          builder: (context,snapshot){
                            final durationState = snapshot.data;
                            final progress = durationState?.position??Duration.zero;
                            final total = durationState?.total ?? Duration.zero;

                            return ProgressBar(
                              progress: progress,
                              total: total,
                              barHeight: 7.0,
                              baseBarColor: Colors.white38.withOpacity(0.9),
                              thumbColor: Colors.blue,
                                thumbRadius : 8.0,
                                thumbGlowColor:Colors.white,
                                thumbGlowRadius : 14.0,
                                thumbCanPaintOutsideBar : true,
                              timeLabelTextStyle: const TextStyle(),
                              onSeek: (duration){
                                _audioPlayer.seek(duration);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    StreamBuilder(
                        stream:_durationStateStream ,
                        builder: (context,snapshot) {
                          final durationState = snapshot.data;
                          final progress = durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                progress.toString().split('.')[0],
                                style: TextStyle(color: Colors.black45,fontSize: 15),
                              ),
                              Flexible(
                                  child: Text(
                                    total.toString().split('.')[0],
                                    style: TextStyle(color: Colors.black38,fontSize: 15),
                                  )
                              )
                            ],
                          );
                        }
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left:0,right: 35),
                      child: Container(
                        width: width*0.65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            IconButton(
                                onPressed: ()async{
                                  Duration duration = Duration(seconds: 1);
                                  if(_audioPlayer.hasPrevious){
                                    await _audioPlayer.seekToPrevious();
                                  }else{
                                    await  _audioPlayer.seek(duration,index: songs.length-1);
                                  }
                                },
                                icon: Icon(Icons.skip_previous_sharp,color: Colors.white70,size: 60,)
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left:0,right: 4),
                              child: IconButton(
                                  onPressed: (){
                                    if(_audioPlayer.playing){
                                       _audioPlayer.pause();
                                      updateIsPlaying();
                                    }else if(_audioPlayer.currentIndex!=null){
                                       _audioPlayer.play();
                                      updateIsPlaying();
                                    }
                                  },
                                  icon: _audioPlayer.playing?Icon(Icons.pause_circle,color: Colors.lightBlueAccent,size: 70):Icon(Icons.play_circle,color: Colors.white70,size: 70,)
                              ),
                            ),

                            IconButton(
                                onPressed: ()async{
                                  Duration duration = Duration(seconds: 1);
                                  if(_audioPlayer.hasNext){
                                    await _audioPlayer.seekToNext();

                                  }else{
                                   await  _audioPlayer.seek(duration,index: 0);
                                  }
                                },
                                icon: Icon(Icons.skip_next,color: Colors.white70,size: 60,)
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),





          ],
        ),
      ),
    )

        :Scaffold (
      appBar: AppBar(
        leading: Container(
          height: 5,
          decoration: BoxDecoration(
            // shape: BoxShape.circle,
              color: Colors.greenAccent
          ),
          child: BackButton(
            onPressed:(){
              setState(() {
                isPlayerVisible = true;
              });
            } ,
            color: Colors.blue,
          ),
        ),
        backgroundColor:Colors.cyanAccent,
        elevation: 1,
        title: Text("All Songs", style: TextStyle(color: Colors.black38),),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.cyanAccent
        ),
        child: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true
          ) ,
          builder: (context,items){
           if(items.data==null){
              return Center(child: CircularProgressIndicator());
            }else if(items.data!.isEmpty){
             return Center(child: Text("No songs Found"));
           }
           else{
             songs.clear();
             songs = items.data!;
             return ListView.builder(
               itemCount: items.data?.length,
                 itemBuilder: (context,index){
                 return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 9,horizontal: 10),
                   child: GestureDetector(
                     onTap: ()async{

                       setState(() {
                         isPlayerVisible = true;
                       });

                       // Uri uri = Uri.parse(items.data![index].uri!);
                       // _audioPlayer.setAudioSource(AudioSource.uri(uri));
                       _audioPlayer.setAudioSource(
                         createPlaylist(items.data!),
                         initialIndex: index
                       );
                       _audioPlayer.play();
                       updateIsPlaying();

                     },
                     child: Container(
                       height:height*0.15,
                       decoration: BoxDecoration(
                         color: Colors.cyan,
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [
                           BoxShadow(color: Colors.black38,offset: Offset(-2,-2),spreadRadius: 0.1,blurStyle: BlurStyle.normal,blurRadius: 10),
                           BoxShadow(color: Colors.white,offset: Offset(3,3),spreadRadius: 0.1,blurStyle: BlurStyle.normal,blurRadius: 8)
                         ]
                       ),
                       child: Center(
                         child: ListTile(
                           title:Text(items.data![index].title,style: TextStyle(color: Colors.white),) ,
                           subtitle: Text(items.data![index].displayName),
                           leading:items.data![index].id>5000?
                           Image.asset("assets/musicIcon.png",fit: BoxFit.cover,)
                               :
                           QueryArtworkWidget(
                               id:items.data![index].id ,
                               type: ArtworkType.AUDIO
                           ),
                           trailing: Icon(Icons.more_vert),
                         ),
                       ),
                     ),
                   ),
                 );
                 }
             );
           }
          },
        ),
      ),
    );
  }

  void requestStoragePermission()async{
      bool status = await _audioQuery.permissionsStatus();
      if(!status){
        await _audioQuery.permissionsRequest();
      }
      setState(() {

      });

  }

  void permissonHandler()async{

      var status = await  Permission.storage.status;
      if(status.isDenied){
        await  Permission.storage.request();
      }
      // setState(() {
      //
      // });
  }

  String formatTime(Duration duration){
    final hours = duration.inHours.toString();
    final minutes = duration.inMinutes.toString();
    final seconds = duration.inSeconds.toString();
    return [
      if(duration.inHours>0) hours,
      minutes,
      seconds
    ].join(":");
  }

  updateIsPlaying()async{
   if(_audioPlayer.playing){
     setState(() {
       isPlaying = true;
     });
   }else{
     setState(() {
       isPlaying= false;
     });
   }
  }

   //updating current Song details
  void _updateCurrentPlayingSongDetail(int index) {
    setState(() {
      if(songs.isNotEmpty){
        currentsongTitle = songs[index].title;
        currentsongsubTitle = songs[index].displayName;
        currentIndex=index;
      }
    });
  }

  //creating playList
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for(var song in songs){
     sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }


}

class DurationState{
  Duration position,total;
  DurationState({required this.position,required this.total});
}
