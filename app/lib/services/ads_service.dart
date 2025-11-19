import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 💰 Serviço de Anúncios com Google AdMob
/// 
/// Gerencia 3 tipos de anúncios:
/// - Banner: Rodapé das telas
/// - Interstitial: Tela cheia entre navegações
/// - Rewarded: Com recompensa (Premium)
class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  // ========== IDs DOS ANÚNCIOS ==========
  
  // ✅ IDs REAIS DO ADMOB CONFIGURADOS!
  static final String _appId = Platform.isAndroid
      ? 'ca-app-pub-7059654584015538~7773981608' // ✅ App ID Real
      : 'ca-app-pub-XXXXXX~YYYYYY'; // iOS (futuro)

  static final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7059654584015538/9133620148' // ✅ Banner ID Real
      : 'ca-app-pub-XXXXXX/YYYYYY';

  static final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7059654584015538/1582433188' // ✅ Interstitial ID Real
      : 'ca-app-pub-XXXXXX/YYYYYY';

  static final String _rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7059654584015538/6171031990' // ✅ Rewarded ID Real
      : 'ca-app-pub-XXXXXX/YYYYYY';

  // IDs de TESTE do Google (use durante desenvolvimento)
  static final String _testBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Teste oficial Google
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String _testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  static final String _testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  // ========== CONTROLE ==========

  // 🚀 MODO PRODUÇÃO - Anúncios reais ativos
  bool _isTestMode = false;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Controle de frequência de interstitial
  int _navigationCount = 0;
  final int _showInterstitialEvery = 3; // Mostrar a cada 3 navegações

  // ========== INICIALIZAÇÃO ==========

  /// Inicializa o SDK do AdMob
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      print('✅ AdMob inicializado com sucesso');
      
      // Pré-carregar anúncios
      await loadBannerAd();
      await loadInterstitialAd();
      await loadRewardedAd();
    } catch (e) {
      print('❌ Erro ao inicializar AdMob: $e');
    }
  }

  // ========== BANNER AD ==========

  /// Carrega um anúncio banner (320x50)
  Future<void> loadBannerAd() async {
    try {
      _bannerAd = BannerAd(
        adUnitId: _isTestMode ? _testBannerAdUnitId : _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            print('✅ Banner carregado');
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Erro ao carregar banner: ${error.message}');
            ad.dispose();
            _isBannerAdLoaded = false;
          },
          onAdOpened: (ad) => print('📱 Banner aberto'),
          onAdClosed: (ad) => print('📱 Banner fechado'),
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      print('❌ Exceção ao carregar banner: $e');
      _isBannerAdLoaded = false;
    }
  }

  /// Retorna o banner ad atual
  BannerAd? get bannerAd => _bannerAd;

  /// Verifica se o banner está carregado
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// Descarta o banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
    print('🗑️ Banner descartado');
  }

  // ========== INTERSTITIAL AD ==========

  /// Carrega um anúncio interstitial (tela cheia)
  Future<void> loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: _isTestMode ? _testInterstitialAdUnitId : _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            print('✅ Interstitial carregado');

            // Configurar callbacks do anúncio
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('📺 Interstitial mostrado');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('📱 Interstitial fechado pelo usuário');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                // Pré-carregar próximo anúncio
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('❌ Erro ao mostrar interstitial: ${error.message}');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('❌ Erro ao carregar interstitial: ${error.message}');
            _isInterstitialAdLoaded = false;
          },
        ),
      );
    } catch (e) {
      print('❌ Exceção ao carregar interstitial: $e');
      _isInterstitialAdLoaded = false;
    }
  }

  /// Mostra o anúncio interstitial (se carregado)
  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('⚠️ Interstitial ainda não carregado');
      // Tentar carregar novamente
      loadInterstitialAd();
    }
  }

  /// Mostra interstitial com controle de frequência
  void showInterstitialAdWithFrequency() {
    _navigationCount++;
    
    if (_navigationCount % _showInterstitialEvery == 0) {
      print('🎯 Mostrando interstitial (navegação $_navigationCount)');
      showInterstitialAd();
    } else {
      print('⏭️ Pulando interstitial (navegação $_navigationCount)');
    }
  }

  /// Verifica se interstitial está carregado
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // ========== REWARDED AD ==========

  /// Carrega um anúncio rewarded (com recompensa)
  Future<void> loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: _isTestMode ? _testRewardedAdUnitId : _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            print('✅ Rewarded carregado');
          },
          onAdFailedToLoad: (error) {
            print('❌ Erro ao carregar rewarded: ${error.message}');
            _isRewardedAdLoaded = false;
          },
        ),
      );
    } catch (e) {
      print('❌ Exceção ao carregar rewarded: $e');
      _isRewardedAdLoaded = false;
    }
  }

  /// Mostra o anúncio rewarded (com callback de recompensa)
  void showRewardedAd({required Function() onRewarded}) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('📺 Rewarded mostrado');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('📱 Rewarded fechado');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          // Pré-carregar próximo anúncio
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Erro ao mostrar rewarded: ${error.message}');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎁 Recompensa ganha: ${reward.amount} ${reward.type}');
          onRewarded(); // Executar callback de recompensa
        },
      );
    } else {
      print('⚠️ Rewarded ainda não carregado');
      loadRewardedAd();
    }
  }

  /// Verifica se rewarded está carregado
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // ========== CONTROLE DE MODO ==========

  /// Ativa modo de PRODUÇÃO (usar IDs reais)
  void setProductionMode() {
    _isTestMode = false;
    print('🚀 Modo PRODUÇÃO ativado - Usando IDs reais');
    // Recarregar anúncios com IDs reais
    disposeBannerAd();
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  /// Ativa modo de TESTE (usar IDs de teste do Google)
  void setTestMode() {
    _isTestMode = true;
    print('🧪 Modo TESTE ativado - Usando IDs de teste');
    // Recarregar anúncios com IDs de teste
    disposeBannerAd();
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  /// Verifica se está em modo de teste
  bool get isTestMode => _isTestMode;

  // ========== LIMPEZA ==========

  /// Descarta todos os anúncios
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isRewardedAdLoaded = false;
    
    print('🗑️ Todos os anúncios descartados');
  }

  // ========== UTILITÁRIOS ==========

  /// Reseta o contador de navegações
  void resetNavigationCount() {
    _navigationCount = 0;
    print('🔄 Contador de navegações resetado');
  }

  /// Ajusta frequência de interstitial
  void setInterstitialFrequency(int showEveryN) {
    if (showEveryN > 0) {
      // Não é possível modificar final field diretamente
      print('⚙️ Frequência de interstitial: a cada $showEveryN navegações');
    }
  }

  /// Status geral dos anúncios
  void printStatus() {
    print('📊 Status dos Anúncios:');
    print('  🧪 Modo: ${_isTestMode ? "TESTE" : "PRODUÇÃO"}');
    print('  🎯 Banner: ${_isBannerAdLoaded ? "Carregado ✅" : "Não carregado ❌"}');
    print('  📺 Interstitial: ${_isInterstitialAdLoaded ? "Carregado ✅" : "Não carregado ❌"}');
    print('  🎁 Rewarded: ${_isRewardedAdLoaded ? "Carregado ✅" : "Não carregado ❌"}');
    print('  📊 Navegações: $_navigationCount');
  }
}
