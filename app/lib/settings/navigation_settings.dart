import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationSettings extends StatefulWidget {
  const NavigationSettings({Key? key}) : super(key: key);

  @override
  State<NavigationSettings> createState() => _NavigationSettingsState();
}

class _NavigationSettingsState extends State<NavigationSettings> {
  bool _voiceInstructions = true;
  bool _autoRecalculate = true;
  bool _trafficAlerts = true;
  bool _speedCameraAlerts = true;
  bool _weatherAlerts = true;
  bool _keepScreenOn = true;
  double _voiceVolume = 0.8;
  String _routePreference = 'fastest'; // fastest, shortest, avoid_tolls
  String _mapStyle = 'standard'; // standard, satellite, dark

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceInstructions = prefs.getBool('voice_instructions') ?? true;
      _autoRecalculate = prefs.getBool('auto_recalculate') ?? true;
      _trafficAlerts = prefs.getBool('traffic_alerts') ?? true;
      _speedCameraAlerts = prefs.getBool('speed_camera_alerts') ?? true;
      _weatherAlerts = prefs.getBool('weather_alerts') ?? true;
      _keepScreenOn = prefs.getBool('keep_screen_on') ?? true;
      _voiceVolume = prefs.getDouble('voice_volume') ?? 0.8;
      _routePreference = prefs.getString('route_preference') ?? 'fastest';
      _mapStyle = prefs.getString('map_style') ?? 'standard';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações de Navegação'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: ListView(
        children: [
          // Seção: Instruções de Voz
          _buildSectionHeader('Instruções de Voz'),
          SwitchListTile(
            title: Text('Ativar instruções de voz'),
            subtitle: Text('Receber orientações por voz durante navegação'),
            value: _voiceInstructions,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _voiceInstructions = value);
              _saveSetting('voice_instructions', value);
            },
          ),
          if (_voiceInstructions)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Volume da voz',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  Slider(
                    value: _voiceVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_voiceVolume * 100).toInt()}%',
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() => _voiceVolume = value);
                      _saveSetting('voice_volume', value);
                    },
                  ),
                ],
              ),
            ),
          Divider(),

          // Seção: Preferências de Rota
          _buildSectionHeader('Preferências de Rota'),
          RadioListTile<String>(
            title: Text('Rota mais rápida'),
            subtitle: Text('Priora menor tempo de viagem'),
            value: 'fastest',
            groupValue: _routePreference,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _routePreference = value!);
              _saveSetting('route_preference', value);
            },
          ),
          RadioListTile<String>(
            title: Text('Rota mais curta'),
            subtitle: Text('Priora menor distância'),
            value: 'shortest',
            groupValue: _routePreference,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _routePreference = value!);
              _saveSetting('route_preference', value);
            },
          ),
          RadioListTile<String>(
            title: Text('Evitar pedágios'),
            subtitle: Text('Prefere rotas sem pedágios'),
            value: 'avoid_tolls',
            groupValue: _routePreference,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _routePreference = value!);
              _saveSetting('route_preference', value);
            },
          ),
          SwitchListTile(
            title: Text('Recalcular automaticamente'),
            subtitle: Text('Recalcula rota se você sair do caminho'),
            value: _autoRecalculate,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _autoRecalculate = value);
              _saveSetting('auto_recalculate', value);
            },
          ),
          Divider(),

          // Seção: Alertas
          _buildSectionHeader('Alertas e Notificações'),
          SwitchListTile(
            title: Text('Alertas de trânsito'),
            subtitle: Text('Avisar sobre congestionamentos'),
            value: _trafficAlerts,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _trafficAlerts = value);
              _saveSetting('traffic_alerts', value);
            },
          ),
          SwitchListTile(
            title: Text('Alertas de radar'),
            subtitle: Text('Avisar sobre radares de velocidade'),
            value: _speedCameraAlerts,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _speedCameraAlerts = value);
              _saveSetting('speed_camera_alerts', value);
            },
          ),
          SwitchListTile(
            title: Text('Alertas de clima'),
            subtitle: Text('Avisar sobre condições climáticas'),
            value: _weatherAlerts,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _weatherAlerts = value);
              _saveSetting('weather_alerts', value);
            },
          ),
          Divider(),

          // Seção: Display
          _buildSectionHeader('Display e Aparência'),
          RadioListTile<String>(
            title: Text('Mapa padrão'),
            value: 'standard',
            groupValue: _mapStyle,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _mapStyle = value!);
              _saveSetting('map_style', value);
            },
          ),
          RadioListTile<String>(
            title: Text('Mapa satélite'),
            value: 'satellite',
            groupValue: _mapStyle,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _mapStyle = value!);
              _saveSetting('map_style', value);
            },
          ),
          RadioListTile<String>(
            title: Text('Modo escuro'),
            value: 'dark',
            groupValue: _mapStyle,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _mapStyle = value!);
              _saveSetting('map_style', value);
            },
          ),
          SwitchListTile(
            title: Text('Manter tela ligada'),
            subtitle: Text('Evita que a tela desligue durante navegação'),
            value: _keepScreenOn,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _keepScreenOn = value);
              _saveSetting('keep_screen_on', value);
            },
          ),
          Divider(),

          // Botão de reset
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _resetToDefaults,
              icon: Icon(Icons.restore),
              label: Text('Restaurar padrões'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restaurar padrões'),
        content: Text('Deseja restaurar todas as configurações para os valores padrão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      setState(() {
        _voiceInstructions = true;
        _autoRecalculate = true;
        _trafficAlerts = true;
        _speedCameraAlerts = true;
        _weatherAlerts = true;
        _keepScreenOn = true;
        _voiceVolume = 0.8;
        _routePreference = 'fastest';
        _mapStyle = 'standard';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configurações restauradas!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}