import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FaithRadioApp());
}

class FaithRadioApp extends StatelessWidget {
  const FaithRadioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faith Radio FM 99.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE8E6F0),
        fontFamily: 'Inter',
      ),
      home: const RadioPlayerScreen(),
    );
  }
}

// Service de gestion audio
class RadioService {
  static final RadioService _instance = RadioService._internal();
  factory RadioService() => _instance;
  RadioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final String streamUrl = 'https://servidor16-3.brlogic.com:7970/live?source=website';
  
  AudioPlayer get audioPlayer => _audioPlayer;
  
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  Future<void> initialize() async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          tag: MediaItem(
            id: '1',
            album: "FM 99.0",
            title: "Faith Radio",
            artUri: Uri.parse('https://via.placeholder.com/200'),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

// Écran principal
class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({Key? key}) : super(key: key);

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen> {
  final RadioService _radioService = RadioService();
  double _volume = 0.7;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _radioService.initialize();
    _radioService.setVolume(_volume);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('À propos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faith Radio FM 99.0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Radio chrétienne du Cameroun'),
            SizedBox(height: 16),
            Text('Diffusion en direct 24h/24'),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E6F0),
      body: SafeArea(
        child: StreamBuilder<PlayerState>(
          stream: _radioService.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing ?? false;

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                   
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          letterSpacing: 1.2,
                          
                        ),
                      ),
                          Text(
                        '          FAITH RADIO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          letterSpacing: 1.2,
                          
                        ),),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: _showMenu,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Card principale
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Icône audio avec cercle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8E6F0),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.graphic_eq,
                              size: 35,
                              color: Colors.deepPurple[400],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Fréquence
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '99',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[900],
                                height: 0.9,
                              ),
                            ),
                            Text(
                              '.0',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: Colors.deepPurple[700],
                                height: 0.9,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Station FM
                        Text(
                          'STATION FM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Nom de la station
                Text(
                  'FM 99.0',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),

                const SizedBox(height: 4),

                // Sous-titre
                Text(
                  'Faith Radio la radio de Dieu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 20),

                // Indicateur LIVE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: playing ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        playing ? 'LIVE' : 'ARRÊTÉ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Actions: Favori, Play, Share
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Favori
                      // IconButton(
                      //   icon: Icon(
                      //     _isFavorite ? Icons.favorite : Icons.favorite_border,
                      //     size: 28,
                      //   ),
                      //   color: _isFavorite ? Colors.red : Colors.grey[400],
                      //   onPressed: () {
                      //     setState(() {
                      //       _isFavorite = !_isFavorite;
                      //     });
                      //   },
                      // ),

                      // Bouton Play/Pause
                      _buildPlayPauseButton(processingState, playing),

                      // Bouton Share (désactivé)
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.ios_share,
                      //     size: 26,
                      //     color: Colors.grey[400],
                      //   ),
                      //   onPressed: () {},
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const SizedBox(height: 25),

                // Contrôle du volume
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_down,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: Colors.deepPurple,
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: Colors.deepPurple,
                          ),
                          child: Slider(
                            value: _volume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              setState(() {
                                _volume = value;
                              });
                              _radioService.setVolume(value);
                            },
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(ProcessingState? processingState, bool playing) {
    final isLoading = processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepPurple[700],
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: isLoading
              ? null
              : () {
                  if (playing) {
                    _radioService.pause();
                  } else {
                    _radioService.play();
                  }
                },
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}