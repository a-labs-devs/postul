# 💰 Guia: Adicionar Anúncios no App POSTUL

## 📋 Visão Geral

Este guia ensina como integrar **Google AdMob** no app POSTUL para gerar receita com anúncios.

**Tipos de anúncios que vamos implementar:**
- 🎯 **Banner** - Anúncio pequeno no rodapé (menos invasivo)
- 📺 **Interstitial** - Anúncio de tela cheia (entre telas)
- 🎁 **Rewarded** - Anúncio com recompensa (usuário ganha algo)

**Estimativa de receita:**
- 📊 **eCPM**: R$ 1,00 - R$ 5,00 (varia por região)
- 💵 **100 usuários/dia**: R$ 30 - R$ 150/mês
- 💰 **1000 usuários/dia**: R$ 300 - R$ 1500/mês

---

## 🎯 Passo 1: Criar Conta no Google AdMob

### 1.1. Acessar AdMob

1. Acesse: https://admob.google.com
2. Faça login com sua conta Google (a mesma do Google Cloud)
3. Clique em **"Get Started"**

### 1.2. Criar Conta AdMob

```
Nome do app: POSTUL
Categoria: Viagens e local
Região: Brasil (BRL)
```

### 1.3. Aceitar Termos

- ✅ Aceitar termos de serviço
- ✅ Configurar informações de pagamento (para receber os ganhos)
- ✅ Definir limite de faturamento (opcional)

---

## 🆔 Passo 2: Criar App no AdMob

### 2.1. Adicionar App

1. No dashboard do AdMob, clique em **"Apps"** → **"Add App"**
2. Escolha: **Android**
3. Preencha:
   ```
   App name: POSTUL
   Platform: Android
   Package name: com.alabsv.postul
   ```
4. Clique em **"Add"**

### 2.2. Copiar App ID

Você receberá um **App ID** no formato:
```
ca-app-pub-1234567890123456~0987654321
```

**⚠️ GUARDE ESTE ID!** Você vai usar no código.

---

## 📱 Passo 3: Criar Unidades de Anúncio

### 3.1. Banner (Rodapé)

1. No AdMob, vá em **"Apps"** → **POSTUL** → **"Ad Units"**
2. Clique em **"Add Ad Unit"**
3. Escolha: **Banner**
4. Configure:
   ```
   Ad unit name: POSTUL Banner Rodapé
   Ad format: Banner (320x50)
   ```
5. Clique em **"Create Ad Unit"**
6. **Copie o Ad Unit ID**: `ca-app-pub-XXXXX/XXXXXXXX`

### 3.2. Interstitial (Tela Cheia)

1. Clique em **"Add Ad Unit"** novamente
2. Escolha: **Interstitial**
3. Configure:
   ```
   Ad unit name: POSTUL Interstitial
   Ad format: Interstitial (Fullscreen)
   ```
4. **Copie o Ad Unit ID**: `ca-app-pub-XXXXX/YYYYYYYY`

### 3.3. Rewarded (Com Recompensa)

1. Clique em **"Add Ad Unit"** novamente
2. Escolha: **Rewarded**
3. Configure:
   ```
   Ad unit name: POSTUL Rewarded Premium
   Reward amount: 1 Semana Premium
   ```
4. **Copie o Ad Unit ID**: `ca-app-pub-XXXXX/ZZZZZZZZ`

---

## 🔧 Passo 4: Adicionar Dependência no Flutter

### 4.1. Editar pubspec.yaml

Adicione no arquivo `app/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # ... suas outras dependências ...
  
  # Google AdMob
  google_mobile_ads: ^5.1.0
```

### 4.2. Instalar Dependência

```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app
flutter pub get
```

---

## 🤖 Passo 5: Configurar Android

### 5.1. Editar AndroidManifest.xml

Arquivo: `app/android/app/src/main/AndroidManifest.xml`

Adicione **dentro da tag `<application>`**:

```xml
<application
    android:label="postul"
    android:icon="@mipmap/ic_launcher">
    
    <!-- ADICIONE ESTAS LINHAS -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-1234567890123456~0987654321"/>
    <!-- FIM DAS LINHAS -->
    
    <activity
        android:name=".MainActivity"
        ...
```

**⚠️ SUBSTITUA** `ca-app-pub-1234567890123456~0987654321` pelo **SEU App ID** real!

### 5.2. Adicionar Permissão de Internet (já tem)

Verifique se tem no `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

## 💻 Passo 6: Criar Serviço de Anúncios

### 6.1. Criar arquivo ads_service.dart

Crie o arquivo: `app/lib/services/ads_service.dart`

```dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  // IDs dos anúncios (SUBSTITUA pelos seus IDs reais)
  static const String _appId = Platform.isAndroid
      ? 'ca-app-pub-1234567890123456~0987654321' // SEU APP ID
      : 'ca-app-pub-XXXXXX~YYYYYY'; // iOS (futuro)

  static const String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1234567890123456/1234567890' // SEU BANNER ID
      : 'ca-app-pub-XXXXXX/YYYYYY';

  static const String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1234567890123456/0987654321' // SEU INTERSTITIAL ID
      : 'ca-app-pub-XXXXXX/YYYYYY';

  static const String _rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1234567890123456/1357924680' // SEU REWARDED ID
      : 'ca-app-pub-XXXXXX/YYYYYY';

  // IDs de TESTE (use durante desenvolvimento)
  static const String _testBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Teste Google
      : 'ca-app-pub-3940256099942544/2934735716';

  static const String _testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  static const String _testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  // Controle de modo de teste
  bool _isTestMode = true; // MUDE PARA false NA PRODUÇÃO

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Inicializar AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    print('✅ AdMob inicializado');
  }

  // ========== BANNER AD ==========

  Future<void> loadBannerAd() async {
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
          print('❌ Erro ao carregar banner: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
        },
      ),
    );

    await _bannerAd!.load();
  }

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // ========== INTERSTITIAL AD ==========

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _isTestMode ? _testInterstitialAdUnitId : _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          print('✅ Interstitial carregado');

          // Configurar callbacks
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('📱 Interstitial fechado');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              // Pré-carregar próximo anúncio
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Erro ao mostrar interstitial: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Erro ao carregar interstitial: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('⚠️ Interstitial ainda não carregado');
      loadInterstitialAd(); // Tentar carregar
    }
  }

  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // ========== REWARDED AD ==========

  Future<void> loadRewardedAd() async {
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
          print('❌ Erro ao carregar rewarded: $error');
          _isRewardedAdLoaded = false;
        },
      ),
    );
  }

  void showRewardedAd({required Function() onRewarded}) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('📱 Rewarded fechado');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          // Pré-carregar próximo anúncio
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Erro ao mostrar rewarded: $error');
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎁 Recompensa ganha: ${reward.amount} ${reward.type}');
          onRewarded();
        },
      );
    } else {
      print('⚠️ Rewarded ainda não carregado');
      loadRewardedAd();
    }
  }

  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Desabilitar modo de teste (PRODUÇÃO)
  void setProductionMode() {
    _isTestMode = false;
    print('🚀 Modo PRODUÇÃO ativado');
  }

  // Ativar modo de teste
  void setTestMode() {
    _isTestMode = true;
    print('🧪 Modo TESTE ativado');
  }

  // Limpar todos os anúncios
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
```

---

## 🎯 Passo 7: Integrar Anúncios no App

### 7.1. Inicializar no main.dart

Edite `app/lib/main.dart`:

```dart
import 'package:postul/services/ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar AdMob
  await AdsService().initialize();
  
  // Pré-carregar anúncios
  await AdsService().loadBannerAd();
  await AdsService().loadInterstitialAd();
  await AdsService().loadRewardedAd();
  
  runApp(const MyApp());
}
```

### 7.2. Adicionar Banner no MapScreen

Edite `app/lib/screens/new/map_screen.dart`:

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads_service.dart';

class _MapScreenState extends State<MapScreen> {
  final AdsService _adsService = AdsService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Seu mapa atual
          GoogleMap(...),
          
          // BANNER NO RODAPÉ
          if (_adsService.isBannerAdLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.white,
                child: AdWidget(ad: _adsService.bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
```

### 7.3. Mostrar Interstitial entre Telas

Quando o usuário navegar para tela de rotas, mostre um anúncio:

```dart
// No botão "Ir até o posto"
onPressed: () {
  // Mostrar anúncio (a cada 3 navegações, por exemplo)
  if (navegacoesCount % 3 == 0) {
    AdsService().showInterstitialAd();
  }
  
  // Aguardar 2 segundos e navegar
  Future.delayed(Duration(seconds: 2), () {
    Navigator.push(context, MaterialPageRoute(...));
  });
}
```

### 7.4. Adicionar Rewarded para Premium

Crie um botão "Ganhar 7 dias Premium":

```dart
ElevatedButton(
  onPressed: () {
    AdsService().showRewardedAd(
      onRewarded: () {
        // Dar 7 dias de premium
        print('🎁 Usuário ganhou 7 dias premium!');
        SharedPreferences.getInstance().then((prefs) {
          final expiry = DateTime.now().add(Duration(days: 7));
          prefs.setString('premium_expiry', expiry.toIso8601String());
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 Você ganhou 7 dias Premium!')),
        );
      },
    );
  },
  child: Text('📺 Assistir anúncio e ganhar Premium'),
)
```

---

## 🧪 Passo 8: Testar Anúncios

### 8.1. Modo de Teste (Desenvolvimento)

Durante desenvolvimento, use **IDs de teste do Google**:
- Já configurado no `AdsService` com `_isTestMode = true`
- Anúncios aparecem como "Test Ad"

### 8.2. Comandos de Teste

```powershell
cd C:\Users\jean_\Documents\GitHub\postul\app
flutter run -d 0082530777
```

**Verifique:**
- ✅ Banner aparece no rodapé
- ✅ Interstitial abre em tela cheia
- ✅ Rewarded mostra botão de recompensa

### 8.3. Ativar Modo Produção

**ANTES DE ENVIAR PARA PLAY STORE**, edite `ads_service.dart`:

```dart
bool _isTestMode = false; // MUDE PARA false
```

E substitua os IDs pelos seus IDs reais do AdMob.

---

## 💰 Passo 9: Otimizar Receita

### 9.1. Estratégias de Monetização

**Banner:**
- Mostrar em todas as telas principais
- Não cobrir conteúdo importante
- Taxa de impressão: ~100% dos usuários

**Interstitial:**
- Mostrar a cada 3-5 navegações
- Não mostrar durante navegação GPS
- Taxa de clique: ~1-3%

**Rewarded:**
- Oferecer benefícios claros (Premium, sem anúncios)
- Mostrar em menu de configurações
- Taxa de conversão: ~10-30%

### 9.2. Frequência de Anúncios

```dart
// Controlar frequência de interstitial
class AdFrequencyController {
  int _navigationCount = 0;
  final int _showEveryNNavigations = 3;
  
  bool shouldShowInterstitial() {
    _navigationCount++;
    return _navigationCount % _showEveryNNavigations == 0;
  }
}
```

### 9.3. Evitar Spam de Anúncios

```dart
// Não mostrar anúncios:
if (isUserPremium) {
  // Sem anúncios para usuários premium
  return;
}

if (isNavigating) {
  // Não mostrar durante navegação
  return;
}
```

---

## 📊 Passo 10: Monitorar Receita

### 10.1. Dashboard do AdMob

1. Acesse: https://admob.google.com
2. Veja métricas:
   - 💰 **Receita diária**
   - 📊 **eCPM** (ganho por 1000 impressões)
   - 📱 **Impressões** (quantas vezes anúncio foi exibido)
   - 👆 **Cliques** (CTR - Click-Through Rate)

### 10.2. Estimativa de Ganhos

```
Cálculo simples:
Usuários ativos/dia: 100
Impressões/usuário: 10
Total impressões: 1000

eCPM médio: R$ 2,00
Receita diária: (1000 / 1000) × R$ 2,00 = R$ 2,00/dia
Receita mensal: R$ 2,00 × 30 = R$ 60,00/mês
```

### 10.3. Pagamento

- 💵 Google paga quando atingir **R$ 200** (mínimo)
- 📅 Pagamento mensal via **transferência bancária**
- 🏦 Configurar dados bancários no AdMob

---

## ⚠️ Políticas e Restrições

### 11.1. Políticas do AdMob

**✅ PERMITIDO:**
- Banners em rodapé/topo
- Interstitial entre telas
- Rewarded com benefícios claros

**❌ PROIBIDO:**
- Clicar nos próprios anúncios
- Forçar usuários a clicar
- Anúncios sobrepostos
- Anúncios enganosos

### 11.2. Violações Resultam em:
- ⚠️ Advertência
- 🚫 Suspensão temporária
- 💀 Ban permanente da conta

---

## 🎯 Checklist Final

Antes de publicar:

- [ ] Conta AdMob criada e verificada
- [ ] App ID configurado no AndroidManifest
- [ ] 3 Ad Units criadas (Banner, Interstitial, Rewarded)
- [ ] IDs de teste substituídos por IDs reais
- [ ] `_isTestMode = false` em produção
- [ ] Anúncios testados em device real
- [ ] Frequência de anúncios otimizada
- [ ] Usuários premium sem anúncios (opcional)
- [ ] Políticas do AdMob revisadas
- [ ] AAB gerado com anúncios integrados

---

## 📞 Próximos Passos

1. **Criar conta AdMob** (15 min)
2. **Adicionar dependência** (5 min)
3. **Copiar código AdsService** (10 min)
4. **Integrar anúncios nas telas** (30 min)
5. **Testar no device** (15 min)
6. **Build release** (5 min)
7. **Publicar na Play Store** (já tem guia)
8. **Aguardar aprovação** (2-7 dias)
9. **Monitorar receita** (diariamente)

---

**🎉 Pronto! Seu app agora gera receita com anúncios!**

**Estimativa realista (100 usuários/dia):**
- 📊 **Banner**: R$ 10-30/mês
- 📺 **Interstitial**: R$ 15-40/mês
- 🎁 **Rewarded**: R$ 5-20/mês
- 💰 **TOTAL**: R$ 30-90/mês

**Com 1.000 usuários/dia: R$ 300-900/mês** 🚀

---

**Última atualização:** 6 de novembro de 2025
