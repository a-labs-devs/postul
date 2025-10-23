import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/postos_service.dart';
// TEMPORARIAMENTE DESABILITADO: import '../services/notificacao_proximidade_service.dart';
import '../services/favoritos_service.dart';
import '../services/rotas_service.dart';
import '../services/navigation_service.dart';
import '../models/posto.dart';
import 'tela_atualizar_preco.dart';
import 'tela_editar_posto.dart';
import 'tela_favoritos.dart';
import '../utils/comparador_precos.dart';
import '../services/precos_service.dart';
import '../services/notificacao_service.dart';
import 'tela_configuracoes_notificacoes.dart';
import '../services/avaliacoes_service.dart';
import '../models/avaliacao.dart';
import 'tela_avaliar_posto.dart';
import '../services/fotos_service.dart';
import 'tela_galeria_fotos.dart';

class TelaMapa extends StatefulWidget {
  final int usuarioId;

  TelaMapa({required this.usuarioId});

  @override
  _TelaMapaState createState() => _TelaMapaState();
}





class _TelaMapaState extends State<TelaMapa> {
  final PrecosService _precosService = PrecosService();
  final FotosService _fotosService = FotosService();  // <-- ADICIONAR AQUI
  final AvaliacoesService _avaliacoesService = AvaliacoesService();  // <-- ADICIONAR AQUI
  
  int get _usuarioId => widget.usuarioId;
  final MapController _mapController = MapController();
  final PostosService _postosService = PostosService();
  final FavoritosService _favoritosService = FavoritosService();
  final RotasService _rotasService = RotasService();
  String _combustivelFiltro = 'Gasolina Comum';
  // ... resto do código
  
  LatLng? _localizacaoAtual;
  LatLng? _ultimaAtualizacao;
  List<Posto> _postos = [];
  bool _carregando = true;
  double _raioBusca = 10.0;
  bool _usarBuscaProximos = true;
  
  StreamSubscription<Position>? _positionStream;
  bool _rastreamentoAtivo = true;
  bool _notificacoesAtivas = true;
  Timer? _timerAtualizacao;
  
  NavigationService? _navigationService;
  NavigationState? _navState;
  StreamSubscription<NavigationState>? _navStateSubscription;
  
  static const double _distanciaMinima = 300.0;
  static const int _tempoAtualizacao = 30;
  static const double _distanciaParado = 50.0;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _timerAtualizacao?.cancel();
    _navStateSubscription?.cancel();
    _navigationService?.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
  await _obterLocalizacao();
  await _carregarPostos();
  
  // INICIALIZAR NOTIFICAÇÕES
  await NotificacaoService.inicializar();
  await NotificacaoService.solicitarPermissao();
  
  _iniciarRastreamento();
}

  Future<void> _obterLocalizacao() async {
    try {
      LocationPermission permissao = await Geolocator.checkPermission();
      
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          _mostrarErro('Permissão de localização negada');
          return;
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        _mostrarErro('Permissão de localização negada permanentemente');
        return;
      }

      Position posicao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _localizacaoAtual = LatLng(posicao.latitude, posicao.longitude);
        _ultimaAtualizacao = _localizacaoAtual;
      });

      _mapController.move(_localizacaoAtual!, 15.0);

    } catch (e) {
      _mostrarErro('Erro ao obter localização: $e');
    }
  }

  void _iniciarRastreamento() {
    if (!_rastreamentoAtivo) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _atualizarPosicao(position);
    });

    _timerAtualizacao = Timer.periodic(
      Duration(seconds: _tempoAtualizacao),
      (timer) {
        if (_rastreamentoAtivo && _localizacaoAtual != null) {
          _verificarNecessidadeAtualizacao();
        }
      },
    );
  }

  void _atualizarPosicao(Position position) {
    final novaLocalizacao = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _localizacaoAtual = novaLocalizacao;
    });

    if (_navState != null) {
      try {
        _mapController.move(novaLocalizacao, 18.0);
        
        if (position.heading != null && position.heading >= 0) {
          _mapController.rotate(-position.heading);
        }
      } catch (e) {
        print('⚠️ Erro ao atualizar posição no mapa: $e');
      }
    } else {
      try {
        _mapController.move(novaLocalizacao, _mapController.camera.zoom);
      } catch (e) {
        print('⚠️ Erro ao mover mapa: $e');
      }
    }
    
    _verificarNecessidadeAtualizacao();
  }

  void _verificarNecessidadeAtualizacao() {
    if (_localizacaoAtual == null || _ultimaAtualizacao == null) return;

    final distancia = Geolocator.distanceBetween(
      _ultimaAtualizacao!.latitude,
      _ultimaAtualizacao!.longitude,
      _localizacaoAtual!.latitude,
      _localizacaoAtual!.longitude,
    );

    if (distancia >= _distanciaMinima) {
      print('📍 Moveu ${distancia.toStringAsFixed(0)}m - Atualizando postos...');
      _ultimaAtualizacao = _localizacaoAtual;
      _carregarPostos(silencioso: true);
      
      // TEMPORARIAMENTE DESABILITADO: Notificações
      /*
      // VERIFICAR NOTIFICAÇÕES
if (_postos.isNotEmpty) {
  final prefs = await SharedPreferences.getInstance();
  final alertasPrecos = prefs.getBool('alertas_precos_baixos') ?? true;
  final alertasProx = prefs.getBool('alertas_proximidade') ?? true;
  final combustivel = prefs.getString('combustivel_preferido') ?? 'gasolina';
  final raio = prefs.getDouble('raio_proximidade') ?? 500.0;

  if (alertasPrecos) {
    await NotificacaoService.verificarPrecosBaixos(
      postos: _postos,
      latitudeAtual: _localizacaoAtual!.latitude,
      longitudeAtual: _localizacaoAtual!.longitude,
      combustivelPreferido: combustivel,
    );
  }

  if (alertasProx) {
    await NotificacaoService.verificarProximidade(
      postos: _postos,
      latitudeAtual: _localizacaoAtual!.latitude,
      longitudeAtual: _localizacaoAtual!.longitude,
      combustivelPreferido: combustivel,
      raioAlerta: raio,
    );
  }
}if (_notificacoesAtivas && _postos.isNotEmpty) {
        NotificacaoProximidadeService.verificarProximidade(
          latitudeAtual: _localizacaoAtual!.latitude,
          longitudeAtual: _localizacaoAtual!.longitude,
          postos: _postos,
          combustivelFiltro: _combustivelFiltro,
        );
        
        NotificacaoProximidadeService.verificarPrecosBaixos(
          postos: _postos,
          combustivelFiltro: _combustivelFiltro,
          latitudeAtual: _localizacaoAtual!.latitude,
          longitudeAtual: _localizacaoAtual!.longitude,
        );
      }
      */
    } else if (distancia < _distanciaParado) {
      print('🛑 Parado (${distancia.toStringAsFixed(0)}m) - Não atualizando');
    }
  }

  void _toggleRastreamento() {
    setState(() {
      _rastreamentoAtivo = !_rastreamentoAtivo;
    });

    if (_rastreamentoAtivo) {
      _iniciarRastreamento();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.gps_fixed, color: Colors.white),
              SizedBox(width: 10),
              Text('✅ Rastreamento ativado'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _positionStream?.cancel();
      _timerAtualizacao?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.gps_off, color: Colors.white),
              SizedBox(width: 10),
              Text('⏸️ Rastreamento pausado'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  
  Future<void> _testarNotificacao() async {
    // TEMPORARIAMENTE DESABILITADO: await NotificacaoProximidadeService.notificarTeste();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Notificações temporariamente desabilitadas'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _carregarPostos({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() {
        _carregando = true;
      });
    }

    try {
      final postos = await _postosService.listarTodos();
      setState(() {
        _postos = postos;
        _carregando = false;
      });
      
      if (silencioso) {
        print('🔄 Postos atualizados em segundo plano (${postos.length} postos)');
      }
    } catch (e) {
      if (!silencioso) {
        _mostrarErro('Erro ao carregar postos: $e');
      }
      setState(() {
        _carregando = false;
      });
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _iniciarNavegacao(Posto posto) async {
    try {
      if (_localizacaoAtual == null) {
        _mostrarErro('Localização atual não disponível');
        return;
      }

      setState(() {
        _carregando = true;
      });

      final destino = LatLng(posto.latitude, posto.longitude);
      
      _navigationService = NavigationService();
      
      _navStateSubscription = _navigationService!.navigationStateController.stream.listen(
        (state) {
          if (!mounted) return;
          
          try {
            setState(() {
              _navState = state;
            });
          } catch (e) {
            print('❌ Erro ao processar estado: $e');
          }
        },
      );
      
      await _navigationService!.startNavigation(_localizacaoAtual!, destino);

      setState(() {
        _carregando = false;
      });

      if (!mounted) return;

      if (_navigationService!.routePoints.isNotEmpty) {
        try {
          _mapController.move(_localizacaoAtual!, 17.0);
        } catch (e) {
          print('⚠️ Erro ao mover mapa: $e');
        }
      }
      
      if (!mounted) return;
      
      await Future.delayed(Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      if (_navState == null) {
        setState(() {});
      }
    } catch (e) {
      print('❌ Erro em _iniciarNavegacao: $e');
      
      setState(() {
        _carregando = false;
      });
      
      _mostrarErro('Erro ao iniciar navegação: $e');
    }
  }

  void _pararNavegacao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Cancelar Navegação?'),
          ],
        ),
        content: Text('Tem certeza que deseja parar a navegação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              _navigationService?.stopNavigation();
              _navStateSubscription?.cancel();
              setState(() {
                _navigationService = null;
                _navState = null;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Sim, Parar'),
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    if (segundos < 60) return '${segundos}s';
    final minutos = segundos ~/ 60;
    if (minutos < 60) return '${minutos} min';
    final horas = minutos ~/ 60;
    final minutosRestantes = minutos % 60;
    return '${horas}h ${minutosRestantes}min';
  }

  String _formatarDistanciaNav(double metros) {
    if (metros < 1000) {
      return '${metros.toInt()} m';
    } else {
      return '${(metros / 1000).toStringAsFixed(1)} km';
    }
  }

  Future<void> _toggleFavorito(Posto posto) async {
    final resultado = await _favoritosService.verificar(
      usuarioId: _usuarioId,
      postoId: posto.id,
    );

    final ehFavorito = resultado['favorito'] as bool;

    if (ehFavorito) {
      final favorito = resultado['dados'];
      if (favorito != null) {
        final sucesso = await _favoritosService.remover(favorito.id);
        
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💔 Removido dos favoritos'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      _mostrarDialogAdicionarFavorito(posto);
    }
  }

  void _mostrarDialogAdicionarFavorito(Posto posto) {
    String combustivelSelecionado = _combustivelFiltro;
    double? precoAlvo;
    bool notificarSempre = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 10),
              Text('Adicionar Favorito'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  posto.nome,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('Combustível para monitorar:'),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: combustivelSelecionado,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Gasolina Comum', 'Gasolina Aditivada', 'Etanol', 'Diesel']
                      .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) {
                      setStateDialog(() {
                        combustivelSelecionado = valor;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                Text('Preço alvo (opcional):'),
                SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Ex: 5.50',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (valor) {
                    precoAlvo = double.tryParse(valor.replaceAll(',', '.'));
                  },
                ),
                SizedBox(height: 8),
                Text('Você será notificado quando atingir este preço',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Notificar sempre que preço cair'),
                  subtitle: Text('Receba alertas mesmo sem preço alvo'),
                  value: notificarSempre,
                  onChanged: (valor) {
                    setStateDialog(() {
                      notificarSempre = valor;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final sucesso = await _favoritosService.adicionar(
                  usuarioId: _usuarioId,
                  postoId: posto.id,
                  combustivelPreferido: combustivelSelecionado,
                  precoAlvo: precoAlvo,
                  notificarSempre: notificarSempre,
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(sucesso ? '❤️ Adicionado aos favoritos!' : '❌ Erro ao adicionar favorito'),
                  backgroundColor: sucesso ? Colors.green : Colors.red,
                ));
              },
              icon: Icon(Icons.favorite),
              label: Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarDeletarPosto(Posto posto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text('Tem certeza que deseja deletar o posto "${posto.nome}"?\n\nEsta ação NÃO pode ser desfeita!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final sucesso = await _postosService.deletarPosto(posto.id);
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sucesso ? '✅ Posto deletado com sucesso!' : '❌ Erro ao deletar posto'),
        backgroundColor: sucesso ? Colors.green : Colors.red,
      ));

      if (sucesso) {
        setState(() {
          _carregando = true;
        });
        await _carregarPostos();
      }
    }
  }

  void _mostrarDetalhePosto(Posto posto) async {
  final resultado = await _favoritosService.verificar(
    usuarioId: _usuarioId,
    postoId: posto.id,
  );
  final ehFavorito = resultado['favorito'] as bool;

  // Buscar preços
  final precos = await _precosService.buscarPrecosPorPosto(posto.id);
  
 // Buscar média de avaliações
final mediaAvaliacao = await _avaliacoesService.obterMedia(posto.id);

// ADICIONAR AQUI - Buscar quantidade de fotos
final totalFotos = await _fotosService.contarFotos(posto.id);

  posto = Posto(
    id: posto.id,
    nome: posto.nome,
    endereco: posto.endereco,
    latitude: posto.latitude,
    longitude: posto.longitude,
    telefone: posto.telefone,
    aberto24h: posto.aberto24h,
    precos: precos,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO
            Row(
              children: [
                Icon(Icons.local_gas_station, color: Colors.blue, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(posto.nome, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            
            // AVALIAÇÕES (LOGO ABAIXO DO NOME)
            if (mediaAvaliacao != null && mediaAvaliacao.totalAvaliacoes > 0) ...[
  SizedBox(height: 10),
  Row(
    children: [
      // Card de Avaliações
      Expanded(
        child: InkWell(
          onTap: () {
            _mostrarAvaliacoes(posto);
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 28),
                SizedBox(width: 8),
                Text(
                  mediaAvaliacao.notaMedia.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '(${mediaAvaliacao.totalAvaliacoes})',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
      
      // ADICIONAR AQUI - Badge de Fotos
      if (totalFotos > 0) ...[
        SizedBox(width: 10),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaGaleriaFotos(
                  posto: posto,
                  usuarioId: _usuarioId,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purple),
            ),
            child: Column(
              children: [
                Icon(Icons.photo_camera, color: Colors.purple, size: 28),
                SizedBox(height: 4),
                Text(
                  '$totalFotos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
],
            
            SizedBox(height: 15),
            
            // ENDEREÇO
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 20),
                SizedBox(width: 5),
                Expanded(child: Text(posto.endereco)),
              ],
            ),
            
            // TELEFONE
            if (posto.telefone != null) ...[
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey, size: 20),
                  SizedBox(width: 5),
                  Text(posto.telefone!),
                ],
              ),
            ],
            
            // HORÁRIO
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  posto.aberto24h ? Icons.schedule : Icons.access_time,
                  color: posto.aberto24h ? Colors.green : Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  posto.aberto24h ? 'Aberto 24h' : 'Horário comercial',
                  style: TextStyle(
                    color: posto.aberto24h ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            
            // PREÇOS
            Text(
              '💰 Preços',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (posto.precos != null && posto.precos!.isNotEmpty)
              ...posto.precos!.map((preco) => Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCombustivelColor(preco.tipo).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _getCombustivelColor(preco.tipo)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatarTipoCombustivel(preco.tipo),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getCombustivelColor(preco.tipo),
                      ),
                    ),
                    Text(
                      'R\$ ${preco.preco.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )).toList()
            else
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    SizedBox(width: 10),
                    Text(
                      'Sem preços cadastrados',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            
            // BOTÕES DE AÇÃO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _iniciarNavegacao(posto);
                },
                icon: Icon(Icons.navigation),
                label: Text('Navegar até aqui'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // BOTÃO AVALIAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaAvaliarPosto(
                        posto: posto,
                        usuarioId: _usuarioId,
                      ),
                    ),
                  );
                  if (resultado == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⭐ Obrigado pela sua avaliação!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.star),
                label: Text('Avaliar Posto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // BOTÃO VER FOTOS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaGaleriaFotos(
                        posto: posto,
                        usuarioId: _usuarioId,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.photo_camera),
                label: Text(totalFotos > 0 ? 'Ver Fotos ($totalFotos)' : 'Adicionar Fotos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // BOTÃO ATUALIZAR PREÇO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaAtualizarPreco(posto: posto, usuarioId: _usuarioId),
                    ),
                  );
                  if (resultado == true) {
                    setState(() {
                      _carregando = true;
                    });
                    _carregarPostos();
                  }
                },
                icon: Icon(Icons.edit),
                label: Text('Atualizar Preço'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            SizedBox(height: 10),
            
            // BOTÃO FAVORITOS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _toggleFavorito(posto);
                },
                icon: Icon(ehFavorito ? Icons.favorite : Icons.favorite_border),
                label: Text(ehFavorito ? 'Remover dos Favoritos' : 'Adicionar aos Favoritos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ehFavorito ? Colors.orange : Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


// FUNÇÕES AUXILIARES FORA
Color _getCombustivelColor(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'gasolina':
    case 'gasolina comum':
      return Colors.green;
    case 'etanol':
      return Colors.orange;
    case 'diesel':
      return Colors.blue;
    case 'gnv':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

String _formatarTipoCombustivel(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'gasolina':
    case 'gasolina comum':
      return '⛽ Gasolina';
    case 'etanol':
      return '🌽 Etanol';
    case 'diesel':
      return '🚛 Diesel';
    case 'gnv':
      return '🔥 GNV';
    default:
      return tipo;
  }
  void _mostrarAvaliacoes(Posto posto) async {
    // ... código da função
  }

  Widget _buildBarraEstrelas(int estrelas, int quantidade, int total) {
    // ... código da função
  }

  String _formatarData(DateTime data) {
    // ... código da função
  }
  
}

 
  


  void _mostrarFiltroCombustivel() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrar por Combustível', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ...['Gasolina Comum', 'Gasolina Aditivada', 'Etanol', 'Diesel']
                .map((tipo) => _buildOpcaoCombustivel(tipo))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoCombustivel(String tipo) {
    final selecionado = _combustivelFiltro == tipo;
    return ListTile(
      leading: Icon(Icons.local_gas_station, color: selecionado ? Colors.blue : Colors.grey),
      title: Text(tipo, style: TextStyle(
        fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
        color: selecionado ? Colors.blue : Colors.black,
      )),
      trailing: selecionado ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() {
          _combustivelFiltro = tipo;
        });
        Navigator.pop(context);
      },
    );
  }

  void _mostrarMenuRaio() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raio de Busca', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('${_raioBusca.toStringAsFixed(0)} km', style: TextStyle(fontSize: 18, color: Colors.blue)),
                ),
                Switch(
                  value: _usarBuscaProximos,
                  onChanged: (valor) {
                    setState(() {
                      _usarBuscaProximos = valor;
                    });
                    Navigator.pop(context);
                    _carregarPostos();
                  },
                  activeColor: Colors.blue,
                ),
                Text('Busca por proximidade'),
              ],
            ),
            if (_usarBuscaProximos) ...[
              Slider(
                value: _raioBusca,
                min: 1,
                max: 50,
                divisions: 49,
                label: '${_raioBusca.toStringAsFixed(0)} km',
                onChanged: (valor) {
                  setState(() {
                    _raioBusca = valor;
                  });
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [5, 10, 20, 50]
                    .map((km) => TextButton(
                          onPressed: () {
                            setState(() {
                              _raioBusca = km.toDouble();
                            });
                          },
                          child: Text('$km km'),
                        ))
                    .toList(),
              ),
            ],
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _carregando = true;
                  });
                  _carregarPostos();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Aplicar Filtro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modoNavegacao = _navState != null;
    
    return Scaffold(
      appBar: modoNavegacao ? null : AppBar(
        title: Text('Postos Próximos'),
        backgroundColor: Colors.blue,
        actions: [
  IconButton(
    icon: Icon(Icons.favorite),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaFavoritos(usuarioId: _usuarioId)),
      );
    },
    tooltip: 'Meus Favoritos',
  ),
  // NOVO: Botão de Configurações de Notificações
  IconButton(
    icon: Icon(
      _notificacoesAtivas ? Icons.notifications_active : Icons.notifications_off,
      color: _notificacoesAtivas ? Colors.white : Colors.white70,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaConfiguracoesNotificacoes(),
        ),
      );
    },
    tooltip: 'Configurar Notificações',
  ),
  IconButton(
    icon: Icon(
      _rastreamentoAtivo ? Icons.gps_fixed : Icons.gps_off,
      color: _rastreamentoAtivo ? Colors.white : Colors.white70,
    ),
    onPressed: _toggleRastreamento,
    tooltip: _rastreamentoAtivo ? 'Desativar rastreamento' : 'Ativar rastreamento',
  ),
  IconButton(
    icon: Icon(Icons.my_location),
    onPressed: () {
      if (_localizacaoAtual != null) {
        _mapController.move(_localizacaoAtual!, 15.0);
      }
    },
  ),
  PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'testar_notificacao') {
        NotificacaoService.enviarNotificacaoTeste();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 Notificação de teste enviada!'),
            backgroundColor: Colors.blue,
          ),
        );
      } else if (value == 'resetar_cache') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Cache resetado'), backgroundColor: Colors.green),
        );
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 'testar_notificacao',
        child: Row(
          children: [
            Icon(Icons.notification_add, color: Colors.blue),
            SizedBox(width: 10),
            Text('Testar Notificação'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'resetar_cache',
        child: Row(
          children: [
            Icon(Icons.refresh, color: Colors.orange),
            SizedBox(width: 10),
            Text('Resetar Cache'),
          ],
        ),
      ),
    ],
  ),
],
       ),
        body: _carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Carregando postos...'),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _localizacaoAtual ?? LatLng(-23.55, -46.63),
                    initialZoom: modoNavegacao ? 18.0 : 13.0,
                    minZoom: 5.0,
                    maxZoom: 20.0,
                    initialRotation: 0.0,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.postul',
                    ),
                    
                    if (_navigationService != null && _navigationService!.routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _navigationService!.routePoints,
                            color: Color(0xFF00D9FF),
                            strokeWidth: 8.0,
                            borderColor: Color(0xFF0088CC),
                            borderStrokeWidth: 3.0,
                          ),
                        ],
                      ),
                    
                    MarkerLayer(
                      markers: [
                        if (_localizacaoAtual != null)
  Marker(
    point: _localizacaoAtual!,
    width: 80,
    height: 80,
    child: StreamBuilder<Position>(
      stream: Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ),
      builder: (context, snapshot) {
        // Pega o heading (direção) da posição GPS
        final heading = snapshot.hasData && snapshot.data!.heading >= 0 
            ? snapshot.data!.heading 
            : 0.0;
        
        // Rotaciona a seta baseado no heading
        return Transform.rotate(
          angle: heading * 0.017453292519943295, // Converte graus para radianos
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_rastreamentoAtivo)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              Container(
                width: modoNavegacao ? 50 : 40,
                height: modoNavegacao ? 50 : 40,
                decoration: BoxDecoration(
                  color: modoNavegacao ? Color(0xFF00D9FF) : Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: modoNavegacao ? 30 : 24,
                ),
              ),
            ],
          ),
        );
      },
    ),
  ),
                        ..._postos.map((posto) {
                          final postoMaisBarato = ComparadorPrecos.encontrarMaisBarato(_postos, _combustivelFiltro);
                          final ehMaisBarato = postoMaisBarato?.id == posto.id;
                          
                          return Marker(
                            point: LatLng(posto.latitude, posto.longitude),
                            width: 90,
                            height: 90,
                            child: GestureDetector(
                              onTap: () => _mostrarDetalhePosto(posto),
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        Icons.local_gas_station,
                                        color: ehMaisBarato ? Colors.green : Colors.red,
                                        size: 40,
                                      ),
                                      if (ehMaisBarato)
                                        Positioned(
                                          right: -5,
                                          top: -5,
                                          child: Container(
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              shape: BoxShape.circle,
                                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
                                            ),
                                            child: Icon(Icons.star, color: Colors.white, size: 16),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ehMaisBarato ? Colors.green.shade100 : Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: ehMaisBarato ? Colors.green : Colors.grey.shade300,
                                        width: ehMaisBarato ? 2 : 1,
                                      ),
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
                                    ),
                                    child: Text(
                                      posto.nome.split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: ehMaisBarato ? FontWeight.bold : FontWeight.normal,
                                        color: ehMaisBarato ? Colors.green.shade800 : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
                
                if (modoNavegacao) ...[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Color(0xFF00D9FF),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: _pararNavegacao,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.close, color: Colors.white, size: 24),
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    _formatarDistanciaNav(_navState!.distanceToNextStep),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF00D9FF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _navigationService!.getManeuverIcon(_navState!.currentStep.instruction),
                                        style: TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      _navState!.currentStep.instruction,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 180,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        if (_localizacaoAtual != null) {
                          _mapController.move(_localizacaoAtual!, 18.0);
                        }
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Color(0xFF00D9FF),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      _formatarTempo(_navState!.estimatedTime),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tempo',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.white30,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      _formatarDistanciaNav(_navState!.remainingDistance),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Distância',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.white30,
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.speed,
                                      color: Color(0xFF00D9FF),
                                      size: 28,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${_navState!.currentSpeed.toInt()}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'km/h',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                
                if (!modoNavegacao) ...[
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      child: Text(
                        '${_postos.length} postos encontrados',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ),
                  if (_rastreamentoAtivo)
                    Positioned(
                      top: 50,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gps_fixed, color: Colors.white, size: 16),
                            SizedBox(width: 5),
                            Text('Rastreamento ativo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  if (_notificacoesAtivas)
                    Positioned(
                      top: 90,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off, color: Colors.white, size: 16),
                            SizedBox(width: 5),
                            Text('Alertas indisponíveis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
     floatingActionButton: modoNavegacao ? null : Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'filtro_combustivel',
            onPressed: _mostrarFiltroCombustivel,
            child: Icon(Icons.filter_alt),
            backgroundColor: Colors.orange,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'raio',
            onPressed: _mostrarMenuRaio,
            icon: Icon(Icons.tune),
            label: Text('${_raioBusca.toStringAsFixed(0)} km'),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  } // <-- FIM do método build

  // ADICIONAR AS 3 FUNÇÕES AQUI:
  
  void _mostrarAvaliacoes(Posto posto) async {
    final avaliacoes = await _avaliacoesService.listarPorPosto(posto.id);
    final mediaAvaliacao = await _avaliacoesService.obterMedia(posto.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Avaliações', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            if (mediaAvaliacao != null) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(mediaAvaliacao.notaMedia.toStringAsFixed(1), style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < mediaAvaliacao.notaMedia.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        SizedBox(height: 5),
                        Text('${mediaAvaliacao.totalAvaliacoes} avaliações', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      child: Column(
                        children: [
                          _buildBarraEstrelas(5, mediaAvaliacao.estrelas5, mediaAvaliacao.totalAvaliacoes),
                          _buildBarraEstrelas(4, mediaAvaliacao.estrelas4, mediaAvaliacao.totalAvaliacoes),
                          _buildBarraEstrelas(3, mediaAvaliacao.estrelas3, mediaAvaliacao.totalAvaliacoes),
                          _buildBarraEstrelas(2, mediaAvaliacao.estrelas2, mediaAvaliacao.totalAvaliacoes),
                          _buildBarraEstrelas(1, mediaAvaliacao.estrelas1, mediaAvaliacao.totalAvaliacoes),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
            
            Expanded(
              child: avaliacoes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_border, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Nenhuma avaliação ainda', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                          SizedBox(height: 8),
                          Text('Seja o primeiro a avaliar!', style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: avaliacoes.length,
                      itemBuilder: (context, index) {
                        final avaliacao = avaliacoes[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        avaliacao.usuarioNome?.substring(0, 1).toUpperCase() ?? 'U',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(avaliacao.usuarioNome ?? 'Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Row(
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                i < avaliacao.nota ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(_formatarData(avaliacao.dataAtualizacao), style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty) ...[
                                  SizedBox(height: 12),
                                  Text(avaliacao.comentario!),
                                ],
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

  Widget _buildBarraEstrelas(int estrelas, int quantidade, int total) {
    final porcentagem = total > 0 ? (quantidade / total) : 0.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$estrelas', style: TextStyle(fontSize: 12)),
          SizedBox(width: 5),
          Icon(Icons.star, color: Colors.amber, size: 14),
          SizedBox(width: 5),
          Expanded(
            child: LinearProgressIndicator(
              value: porcentagem,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          SizedBox(width: 8),
          Text('$quantidade', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);
    
    if (diferenca.inDays == 0) {
      if (diferenca.inHours == 0) {
        return '${diferenca.inMinutes}m atrás';
      }
      return '${diferenca.inHours}h atrás';
    } else if (diferenca.inDays < 7) {
      return '${diferenca.inDays}d atrás';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }

} // <-- FIM da classe _TelaMapaState