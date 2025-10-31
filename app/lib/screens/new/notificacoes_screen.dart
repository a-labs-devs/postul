import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

/// 🔔 Tela de Notificações
class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  final List<NotificacaoItem> _notificacoes = [
    NotificacaoItem(
      titulo: 'Preço baixo encontrado!',
      descricao: 'Shell Paulista está com gasolina a R\$ 5,89',
      tipo: TipoNotificacao.preco,
      dataHora: DateTime.now().subtract(const Duration(hours: 1)),
      lida: false,
    ),
    NotificacaoItem(
      titulo: 'Posto próximo',
      descricao: 'Você está a 500m do Posto Ipiranga',
      tipo: TipoNotificacao.proximidade,
      dataHora: DateTime.now().subtract(const Duration(hours: 3)),
      lida: false,
    ),
    NotificacaoItem(
      titulo: 'Nova avaliação',
      descricao: 'Seu posto favorito recebeu uma nova avaliação',
      tipo: TipoNotificacao.avaliacao,
      dataHora: DateTime.now().subtract(const Duration(days: 1)),
      lida: true,
    ),
    NotificacaoItem(
      titulo: 'Promoção especial!',
      descricao: '15% de desconto no Shell Box até sexta-feira',
      tipo: TipoNotificacao.promocao,
      dataHora: DateTime.now().subtract(const Duration(days: 2)),
      lida: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final naoLidas = _notificacoes.where((n) => !n.lida).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificações',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (naoLidas > 0)
            TextButton(
              onPressed: _marcarTodasComoLidas,
              child: Text(
                'Marcar todas',
                style: AppTypography.labelMedium.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _notificacoes.isEmpty
          ? _buildVazio()
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space8),
              itemCount: _notificacoes.length,
              itemBuilder: (context, index) {
                final notificacao = _notificacoes[index];
                return _buildNotificacaoCard(notificacao, index);
              },
            ),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColors.outline,
          ),
          SizedBox(height: AppSpacing.space16),
          Text(
            'Nenhuma notificação',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.space8),
          Text(
            'Você está em dia!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificacaoCard(NotificacaoItem notificacao, int index) {
    return Dismissible(
      key: Key('notificacao_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notificacoes.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificação removida')),
        );
      },
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.space24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: notificacao.lida ? AppColors.surface : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: notificacao.lida ? AppColors.outline.withOpacity(0.2) : AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          leading: _buildIconeNotificacao(notificacao.tipo),
          title: Text(
            notificacao.titulo,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: notificacao.lida ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.space4),
              Text(
                notificacao.descricao,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.space4),
              Text(
                _formatarDataHora(notificacao.dataHora),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          trailing: !notificacao.lida
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            if (!notificacao.lida) {
              setState(() {
                notificacao.lida = true;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildIconeNotificacao(TipoNotificacao tipo) {
    IconData icone;
    Color cor;

    switch (tipo) {
      case TipoNotificacao.preco:
        icone = Icons.trending_down;
        cor = Colors.green;
        break;
      case TipoNotificacao.proximidade:
        icone = Icons.location_on;
        cor = AppColors.primary;
        break;
      case TipoNotificacao.avaliacao:
        icone = Icons.star;
        cor = Colors.orange;
        break;
      case TipoNotificacao.promocao:
        icone = Icons.local_offer;
        cor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icone, color: cor, size: 24),
    );
  }

  String _formatarDataHora(DateTime dataHora) {
    final agora = DateTime.now();
    final diferenca = agora.difference(dataHora);

    if (diferenca.inMinutes < 60) {
      return 'Há ${diferenca.inMinutes} min';
    } else if (diferenca.inHours < 24) {
      return 'Há ${diferenca.inHours}h';
    } else if (diferenca.inDays < 7) {
      return 'Há ${diferenca.inDays}d';
    } else {
      return '${dataHora.day}/${dataHora.month}/${dataHora.year}';
    }
  }

  void _marcarTodasComoLidas() {
    setState(() {
      for (var notificacao in _notificacoes) {
        notificacao.lida = true;
      }
    });
  }
}

// ===== MODELOS =====

enum TipoNotificacao {
  preco,
  proximidade,
  avaliacao,
  promocao,
}

class NotificacaoItem {
  final String titulo;
  final String descricao;
  final TipoNotificacao tipo;
  final DateTime dataHora;
  bool lida;

  NotificacaoItem({
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.dataHora,
    this.lida = false,
  });
}
