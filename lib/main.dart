import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() {
  runApp(const MyFamilyOttApp());
}

class MyFamilyOttApp extends StatelessWidget {
  const MyFamilyOttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리 가족 홈 OTT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141414),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          surface: Color(0xFF141414),
        ),
      ),
      home: const ProfileSelectScreen(),
    );
  }
}

// 1. 프로필 선택 화면
class ProfileSelectScreen extends StatelessWidget {
  const ProfileSelectScreen({super.key});

  final List> profiles = const [
    {'name': '아빠', 'color': Colors.blue, 'icon': Icons.person},
    {'name': '엄마', 'color': Colors.purple, 'icon': Icons.face},
    {'name': '아이', 'color': Colors.orange, 'icon': Icons.child_care},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '누가 시청 중인가요?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: profiles.map((p) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen(profileName: p['name'])),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: p['color'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(p['icon'], size: 55, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p['name'],
                          style: const TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. 넷플릭스 메인 홈 화면
class HomeScreen extends StatelessWidget {
  final String profileName;
  const HomeScreen({super.key, required this.profileName});

  final List> mediaList = const [
    {
      'title': '인터스텔라 (예시)',
      'poster': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    },
    {
      'title': '애니메이션 (예시)',
      'poster': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    },
    {
      'title': '자연 다큐멘터리 (예시)',
      'poster': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MY OTT', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text('$profileName 님 시청 중', style: const TextStyle(color: Colors.white70)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 대표 배너
            Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1000'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          title: mediaList[0]['title']!,
                          videoUrl: mediaList[0]['url']!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('바로 재생'),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('우리 가족 추천 콘텐츠', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            // 가로 슬라이더 목록
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: mediaList.length,
                itemBuilder: (context, index) {
                  final item = mediaList[index];
                  return Container(
                    width: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(title: item['title']!, videoUrl: item['url']!),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(item['poster']!, height: 150, width: 130, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 6),
                          Text(item['title']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. 내장 비디오 플레이어 화면
class PlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  const PlayerScreen({super.key, required this.title, required this.videoUrl});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFE50914),
        handleColor: const Color(0xFFE50914),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(widget.title)),
      body: Center(
        child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(color: Color(0xFFE50914)),
      ),
    );
  }
}
