import 'package:flutter/material.dart';
import '../models/posto.dart';
import '../services/precos_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/custom_dropdown.dart';
import '../widgets/modals/custom_snackbar.dart';

class TelaAtualizarPreco extends StatefulWidget {
  final Posto posto;
  final int usuarioId;

  const TelaAtualizarPreco({
    super.key,
    required this.posto,
    required this.usuarioId,
  });

  @override
  _TelaAtualizarPrecoState createState() => _TelaAtualizarPrecoState();
}

class _TelaAtualizarPrecoState extends State<TelaAtualizarPreco> {
  final _formKey = GlobalKey<FormState>();
  final _precoController = TextEditingController();
  final _precosService = PrecosService();
  
  String _tipoCombustivelSelecionado = 'Gasolina Comum';
  bool _carregando = false;

  final List<String> _tiposCombustivel = [
    'Gasolina Comum',
    'Gasolina Aditivada',
    'Etanol',
    'Diesel',
    'Diesel S10',
    'GNV',
  ];

  @override
  void dispose() {
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _atualizarPreco() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      final preco = double.parse(_precoController.text.replaceAll(',', '.'));

      final resultado = await _precosService.atualizarPreco(
        postoId: widget.posto.id,
        tipoCombustivel: _tipoCombustivelSelecionado,
        preco: preco,
        usuarioId: widget.usuarioId,
      );

      setState(() {
        _carregando = false;
      });

      if (resultado['sucesso']) {
        if (!mounted) return;
        
        CustomSnackbar.show(
          context,
          message: resultado['mensagem'],
          type: SnackbarType.success,
        );
        
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        
        CustomSnackbar.show(
          context,
          message: resultado['mensagem'],
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Atualizar Preço',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card do Posto
              Container(
                padding: EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.space12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.local_gas_station,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.posto.nome,
                            style: AppTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.space4),
                          Text(
                            widget.posto.endereco,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.space32),
              
              // Título da Seção
              Text(
                'Informações do Combustível',
                style: AppTypography.titleLarge,
              ),
              SizedBox(height: AppSpacing.space16),
              
              // Dropdown de Tipo de Combustível
              CustomDropdown<String>(
                value: _tipoCombustivelSelecionado,
                label: 'Tipo de Combustível',
                prefixIcon: Icons.local_gas_station,
                items: _tiposCombustivel.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _tipoCombustivelSelecionado = valor!;
                  });
                },
              ),
              
              SizedBox(height: AppSpacing.space20),
              
              // Campo de Preço
              TextFormField(
                controller: _precoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Preço (R\$)',
                  hintText: 'Ex: 5.89',
                  labelStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  prefixIcon: const Icon(
                    Icons.attach_money,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.error, width: 1),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço';
                  }
                  final preco = double.tryParse(value.replaceAll(',', '.'));
                  if (preco == null || preco <= 0) {
                    return 'Preço inválido';
                  }
                  if (preco > 50) {
                    return 'Preço muito alto. Verifique o valor.';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: AppSpacing.space16),
              
              // Informação Adicional
              Container(
                padding: EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.space12),
                    Expanded(
                      child: Text(
                        'Ao atualizar, você estará contribuindo com a comunidade. Obrigado!',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.space32),
              
              // Botão de Atualizar
              PrimaryButton(
                label: 'Atualizar Preço',
                onPressed: _carregando ? null : _atualizarPreco,
                isLoading: _carregando,
                icon: Icons.upload,
              ),
              
              SizedBox(height: AppSpacing.space16),
              
              // Texto de Rodapé
              Center(
                child: Text(
                  'Última atualização será registrada em seu nome',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}