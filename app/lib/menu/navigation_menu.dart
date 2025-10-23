import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  final VoidCallback onAlternativeRoute;
  final VoidCallback onReportIncident;
  final VoidCallback onSettings;
  final VoidCallback onAddStop;
  final VoidCallback onShare;

  const NavigationMenu({
    Key? key,
    required this.onAlternativeRoute,
    required this.onReportIncident,
    required this.onSettings,
    required this.onAddStop,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Título
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Opções de Navegação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Opções
          _buildMenuItem(
            icon: Icons.alt_route,
            iconColor: Colors.orange,
            title: 'Rota Alternativa',
            subtitle: 'Ver outras rotas disponíveis',
            onTap: () {
              Navigator.pop(context);
              onAlternativeRoute();
            },
          ),
          _buildMenuItem(
            icon: Icons.add_location,
            iconColor: Colors.blue,
            title: 'Adicionar Parada',
            subtitle: 'Incluir um ponto no caminho',
            onTap: () {
              Navigator.pop(context);
              onAddStop();
            },
          ),
          _buildMenuItem(
            icon: Icons.warning,
            iconColor: Colors.red,
            title: 'Reportar Incidente',
            subtitle: 'Alertar sobre acidente ou problema',
            onTap: () {
              Navigator.pop(context);
              onReportIncident();
            },
          ),
          _buildMenuItem(
            icon: Icons.share,
            iconColor: Colors.green,
            title: 'Compartilhar Localização',
            subtitle: 'Enviar sua posição para contatos',
            onTap: () {
              Navigator.pop(context);
              onShare();
            },
          ),
          _buildMenuItem(
            icon: Icons.settings,
            iconColor: Colors.grey.shade700,
            title: 'Configurações',
            subtitle: 'Ajustar preferências de navegação',
            onTap: () {
              Navigator.pop(context);
              onSettings();
            },
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// Dialog para reportar incidente
class ReportIncidentDialog extends StatefulWidget {
  final Function(String type, String description) onReport;

  const ReportIncidentDialog({
    Key? key,
    required this.onReport,
  }) : super(key: key);

  @override
  State<ReportIncidentDialog> createState() => _ReportIncidentDialogState();
}

class _ReportIncidentDialogState extends State<ReportIncidentDialog> {
  String _selectedType = 'traffic';
  final TextEditingController _descriptionController = TextEditingController();

  final Map<String, IncidentTypeInfo> _incidentTypes = {
    'traffic': IncidentTypeInfo(
      icon: Icons.traffic,
      label: 'Trânsito Lento',
      color: Colors.orange,
    ),
    'accident': IncidentTypeInfo(
      icon: Icons.car_crash,
      label: 'Acidente',
      color: Colors.red,
    ),
    'police': IncidentTypeInfo(
      icon: Icons.local_police,
      label: 'Polícia',
      color: Colors.blue,
    ),
    'hazard': IncidentTypeInfo(
      icon: Icons.warning,
      label: 'Perigo na Via',
      color: Colors.yellow.shade800,
    ),
    'construction': IncidentTypeInfo(
      icon: Icons.construction,
      label: 'Obra',
      color: Colors.brown,
    ),
    'closed': IncidentTypeInfo(
      icon: Icons.block,
      label: 'Via Fechada',
      color: Colors.grey.shade700,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reportar Incidente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            Text(
              'Tipo de incidente:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 10),
            
            // Grid de tipos de incidente
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _incidentTypes.length,
              itemBuilder: (context, index) {
                final type = _incidentTypes.keys.elementAt(index);
                final info = _incidentTypes[type]!;
                final isSelected = _selectedType == type;
                
                return InkWell(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? info.color.withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? info.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          info.icon,
                          color: isSelected ? info.color : Colors.grey.shade600,
                          size: 30,
                        ),
                        SizedBox(height: 5),
                        Text(
                          info.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? info.color : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 20),
            
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Adicione detalhes sobre o incidente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
              maxLines: 3,
            ),
            
            SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    widget.onReport(
                      _selectedType,
                      _descriptionController.text,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Reportar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

class IncidentTypeInfo {
  final IconData icon;
  final String label;
  final Color color;

  IncidentTypeInfo({
    required this.icon,
    required this.label,
    required this.color,
  });
}