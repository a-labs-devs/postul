import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notificacao_service.dart';

class TelaConfiguracoesNotificacoes extends StatefulWidget {
  @override
  _TelaConfiguracoesNotificacoesState createState() => _TelaConfiguracoesNotificacoesState();
}

class _TelaConfiguracoesNotificacoesState extends State<TelaConfiguracoesNotificacoes> {
  bool _notificacoesAtivas = true;
  bool _alertasPrecosBaixos = true;
  bool _alertasProximidade = true;
  String _combustivelPreferido = 'gasolina';
  double _descontoMinimo = 10.0;
  double _raioProximidade = 500.0;
  bool _modoSilencioso = false;
  TimeOfDay _inicioSilencio = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _fimSilencio = TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _notificacoesAtivas = prefs.getBool('notificacoes_ativas') ?? true;
      _alertasPrecosBaixos = prefs.getBool('alertas_precos_baixos') ?? true;
      _alertasProximidade = prefs.getBool('alertas_proximidade') ?? true;
      _combustivelPreferido = prefs.getString('combustivel_preferido') ?? 'gasolina';
      _descontoMinimo = prefs.getDouble('desconto_minimo') ?? 10.0;
      _raioProximidade = prefs.getDouble('raio_proximidade') ?? 500.0;
      _modoSilencioso = prefs.getBool('modo_silencioso') ?? false;
    });
  }

  Future<void> _salvarConfiguracao(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações de Notificações'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ATIVAR/DESATIVAR NOTIFICAÇÕES
          Card(
            elevation: 2,
            child: SwitchListTile(
              value: _notificacoesAtivas,
              onChanged: (value) async {
                setState(() => _notificacoesAtivas = value);
                await NotificacaoService.setNotificacoesHabilitadas(value);
                await _salvarConfiguracao('notificacoes_ativas', value);
                
                if (value) {
                  await NotificacaoService.solicitarPermissao();
                  await NotificacaoService.enviarNotificacaoTeste();
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? '✅ Notificações ativadas!' : '❌ Notificações desativadas'),
                    backgroundColor: value ? Colors.green : Colors.grey,
                  ),
                );
              },
              title: Text(
                'Notificações',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text('Receber alertas sobre preços e postos'),
              secondary: Icon(
                _notificacoesAtivas ? Icons.notifications_active : Icons.notifications_off,
                color: _notificacoesAtivas ? Colors.blue : Colors.grey,
                size: 32,
              ),
            ),
          ),

          SizedBox(height: 20),

          // TIPOS DE ALERTAS
          if (_notificacoesAtivas) ...[
            Text(
              'Tipos de Alertas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),

            Card(
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile(
                    value: _alertasPrecosBaixos,
                    onChanged: (value) async {
                      setState(() => _alertasPrecosBaixos = value);
                      await _salvarConfiguracao('alertas_precos_baixos', value);
                    },
                    title: Text('💰 Preços Baixos'),
                    subtitle: Text('Alertar quando encontrar preços muito baratos'),
                    secondary: Icon(Icons.attach_money, color: Colors.green),
                  ),
                  Divider(height: 1),
                  SwitchListTile(
                    value: _alertasProximidade,
                    onChanged: (value) async {
                      setState(() => _alertasProximidade = value);
                      await _salvarConfiguracao('alertas_proximidade', value);
                    },
                    title: Text('📍 Postos Próximos'),
                    subtitle: Text('Alertar quando passar perto de postos'),
                    secondary: Icon(Icons.location_on, color: Colors.blue),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // COMBUSTÍVEL PREFERIDO
            Text(
              'Combustível Preferido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),

            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOpcaoCombustivel('⛽ Gasolina', 'gasolina', Colors.green),
                    _buildOpcaoCombustivel('🌽 Etanol', 'etanol', Colors.orange),
                    _buildOpcaoCombustivel('🚛 Diesel', 'diesel', Colors.blue),
                    _buildOpcaoCombustivel('🔥 GNV', 'gnv', Colors.purple),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // CONFIGURAÇÕES AVANÇADAS
            Text(
              'Configurações Avançadas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),

            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desconto Mínimo para Alerta',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _descontoMinimo,
                            min: 5,
                            max: 30,
                            divisions: 5,
                            label: '${_descontoMinimo.toInt()}%',
                            onChanged: (value) {
                              setState(() => _descontoMinimo = value);
                            },
                            onChangeEnd: (value) async {
                              await _salvarConfiguracao('desconto_minimo', value);
                            },
                          ),
                        ),
                        Text(
                          '${_descontoMinimo.toInt()}%',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Text(
                      'Alertar apenas se for pelo menos ${_descontoMinimo.toInt()}% mais barato',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Raio de Proximidade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _raioProximidade,
                            min: 100,
                            max: 2000,
                            divisions: 19,
                            label: '${(_raioProximidade / 1000).toStringAsFixed(1)} km',
                            onChanged: (value) {
                              setState(() => _raioProximidade = value);
                            },
                            onChangeEnd: (value) async {
                              await _salvarConfiguracao('raio_proximidade', value);
                            },
                          ),
                        ),
                        Text(
                          '${(_raioProximidade / 1000).toStringAsFixed(1)} km',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Text(
                      'Alertar quando chegar a ${(_raioProximidade / 1000).toStringAsFixed(1)} km de um posto',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // MODO SILENCIOSO
            Card(
              elevation: 2,
              child: SwitchListTile(
                value: _modoSilencioso,
                onChanged: (value) async {
                  setState(() => _modoSilencioso = value);
                  await _salvarConfiguracao('modo_silencioso', value);
                },
                title: Text('🌙 Modo Silencioso'),
                subtitle: Text(
                  _modoSilencioso
                      ? 'Sem notificações das ${_inicioSilencio.format(context)} às ${_fimSilencio.format(context)}'
                      : 'Receber notificações 24h',
                ),
                secondary: Icon(Icons.bedtime, color: Colors.indigo),
              ),
            ),

            SizedBox(height: 20),

            // BOTÃO TESTE
            ElevatedButton.icon(
              onPressed: () async {
                await NotificacaoService.enviarNotificacaoTeste();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🔔 Notificação de teste enviada!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: Icon(Icons.notifications),
              label: Text('Enviar Notificação de Teste'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOpcaoCombustivel(String nome, String valor, Color cor) {
    final selecionado = _combustivelPreferido == valor;
    
    return InkWell(
      onTap: () async {
        setState(() => _combustivelPreferido = valor);
        await _salvarConfiguracao('combustivel_preferido', valor);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selecionado ? cor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selecionado ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selecionado ? cor : Colors.grey,
            ),
            SizedBox(width: 12),
            Text(
              nome,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                color: selecionado ? cor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}