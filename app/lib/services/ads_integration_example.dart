// 📝 EXEMPLO: Como adicionar Banner no MapScreen
// 
// Cole este código no arquivo: app/lib/screens/new/map_screen.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads_service.dart';

class _MapScreenState extends State<MapScreen> {
  final AdsService _adsService = AdsService();
  
  @override
  void initState() {
    super.initState();
    // Carregar banner quando a tela iniciar
    _adsService.loadBannerAd();
  }
  
  @override
  void dispose() {
    // Limpar banner quando sair da tela
    _adsService.disposeBannerAd();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // SEU MAPA ATUAL
          GoogleMap(
            // ... suas configurações atuais ...
          ),
          
          // POSTOS NA LISTA
          // ... seu código atual de lista de postos ...
          
          // 💰 BANNER NO RODAPÉ (ADICIONE ISTO)
          if (_adsService.isBannerAdLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.white,
                alignment: Alignment.center,
                child: AdWidget(ad: _adsService.bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}

// ========================================
// EXEMPLO 2: Interstitial ao navegar
// ========================================

// No botão "Ir até o posto", adicione:

onPressed: () {
  // Mostrar interstitial (a cada 3 navegações)
  AdsService().showInterstitialAdWithFrequency();
  
  // Aguardar 2 segundos para o anúncio fechar (se mostrou)
  Future.delayed(Duration(seconds: 2), () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteSelectionScreen(
          posto: posto,
          origem: origem,
        ),
      ),
    );
  });
}

// ========================================
// EXEMPLO 3: Rewarded para Premium
// ========================================

// Crie um botão nas configurações:

ElevatedButton.icon(
  onPressed: () {
    AdsService().showRewardedAd(
      onRewarded: () async {
        // Dar 7 dias de premium
        final prefs = await SharedPreferences.getInstance();
        final expiry = DateTime.now().add(Duration(days: 7));
        await prefs.setString('premium_expiry', expiry.toIso8601String());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Parabéns! Você ganhou 7 dias Premium!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );
  },
  icon: Icon(Icons.play_circle_filled),
  label: Text('Assistir anúncio e ganhar 7 dias Premium'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.purple,
    padding: EdgeInsets.all(16),
  ),
)
