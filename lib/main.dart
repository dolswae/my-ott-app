import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
          surface: Color(0xFF1F1F1F),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

// 초기 접속 및 설정 확인 화면
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedConfig();
  }

  Future<void> _checkSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final nasUrl = prefs.getString('nas_url');
    final nasSid = prefs.getString('nas_sid');

    if (mounted) {
      if (nasUrl != null && nasSid != null && nasUrl.isNotEmpty && nasSid.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSelectScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NasConfigScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
    );
  }
}

// 1. 시놀로지 NAS 연결 설정 화면
class NasConfigScreen extends StatefulWidget {
  const NasConfigScreen({super.key});

  @override
  State<NasConfigScreen> createState() => _NasConfigScreenState();
}

class _NasConfigScreenState extends State<NasConfigScreen> {
  final _urlController = TextEditingController(text: 'http://192.168.0.10:5000');
  final _userController = TextEditingController();
  final _pwdController = TextEditingController();
  final _folderController = TextEditingController(text: '/video');
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _connectToSynology() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final baseUrl = _urlController.text.trim().replaceAll(RegExp(r'/+$'), '');
    final account = _userController.text.trim();
    final passwd = _pwdController.text.trim();
    final folderPath = _folderController.text.trim();

    try {
      // 시놀로지 DSM FileStation Auth API 로그인 요청
      final loginUrl = Uri.parse(
          '$baseUrl/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account=$account&passwd=$passwd&session=FileStation&format=sid');

      final res = await http.get(loginUrl).timeout(const Duration(seconds: 8));
      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        final sid = data['data']['sid'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nas_url', baseUrl);
        await prefs.setString('nas_sid', sid);
        await prefs.setString('nas_folder', folderPath);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSelectScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = '로그인 실패: 아이디/비밀번호 또는 2차 인증 여부를 확인하세요.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '연결 오류: NAS 주소와 포트(기본 5000)를 확인해 주세요.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시놀로지 NAS 연결 설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.dns_rounded, size: 64, color: Color(0xFFE50914)),
                const SizedBox(height: 16),
                const Text(
                  '홈 OTT - NAS 연결',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'NAS 주소 (IP 또는 QuickConnect/DDNS)',
                    hintText: 'http://192.168.0.10:5000',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: '시놀로지 사용자 ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pwdController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _folderController,
                  decoration: const InputDecoration(
                    labelText: '영상 공유 폴더 경로',
                    hintText: '/video',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _connectToSynology,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('연결하고 OTT 시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. 가족 프로필 선택 화면
class ProfileSelectScreen extends StatelessWidget {
  const ProfileSelectScreen({super.key});

  final List> profiles = const [
    {'name': '아빠', 'color': Colors.blue, 'icon': Icons.person},
    {'name': '엄마', 'color': Colors.purple, 'icon': Icons.face},
    {'name': '딸', 'color': Colors.pinkAccent, 'icon': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'NAS 재설정',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NasConfigScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '누가 시청 중인가요?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapWrapAlignment.center,
              children: profiles.map((p) {
                return InkWell(
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
                      Text(p['name'], style: const TextStyle(fontSize: 18, color: Colors.white70)),
                    ],
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

// 3. 넷플릭스 메인 홈 화면 (시놀로지 파일 실시간 로드)
class HomeScreen extends StatefulWidget {
  final String profileName;
  const HomeScreen({super.key, required this.profileName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List> _videoList = [];
  bool _isLoading = true;
  String? _nasUrl;
  String? _nasSid;

  @override
  void initState() {
    super.initState();
    _loadVideosFromSynology();
  }

  Future<void> _loadVideosFromSynology() async {
    final prefs = await SharedPreferences.getInstance();
    _nasUrl = prefs.getString('nas_url') ?? '';
    _nasSid = prefs.getString('nas_sid') ?? '';
    final folderPath = prefs.getString('nas_folder') ?? '/video';

    final listUrl = Uri.parse(
        '$_nasUrl/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list&folder_path=$folderPath&_sid=$_nasSid');

    try {
      final res = await http.get(listUrl);
      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        final List files = data['data']['files'];
        final List> videos = [];

        for (var file in files) {
          final isDir = file['isdir'] == true;
          final name = file['name'] as String;

          // 비디오 확장자 필터링
          if (!isDir && (name.endsWith('.mp4') || name.endsWith('.mkv') || name.endsWith('.avi') || name.endsWith('.mov'))) {
            final filePath = file['path'] as String;
            final streamUrl = '$_nasUrl/webapi/entry.cgi?api=SYNO.FileStation.Download&version=2&method=download&path=${Uri.encodeComponent(filePath)}&mode=open&_sid=$_nasSid';

            videos.add({
              'title': name,
              'url': streamUrl,
              'poster': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500', // 기본 영화 포스터 배경
            });
          }
        }

        setState(() {
          _videoList = videos;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

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
              child: Text('${widget.profileName} 님 시청 중', style: const TextStyle(color: Colors.white70)),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : _videoList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.movie_filter_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('지정한 폴더에 영상 파일이 없거나 폴더 경로가 잘못되었습니다.', style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NasConfigScreen())),
                        child: const Text('NAS 설정 다시 확인하기', style: TextStyle(color: Color(0xFFE50914))),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 대표 배너
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(_videoList.first['poster']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _videoList.first['title']!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlayerScreen(
                                        title: _videoList.first['title']!,
                                        videoUrl: _videoList.first['url']!,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('재생'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('NAS 라이브러리 목록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      // 가로 카드 슬라이더
                      SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _videoList.length,
                          itemBuilder: (context, index) {
                            final item = _videoList[index];
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
                                      child: Container(
                                        height: 140,
                                        width: 130,
                                        color: Colors.grey[900],
                                        child: const Center(
                                          child: Icon(Icons.play_circle_fill, size: 48, color: Color(0xFFE50914)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['title']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
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

// 4. 비디오 플레이어 화면
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
