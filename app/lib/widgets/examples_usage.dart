import 'package:flutter/material.dart';
import 'package:postul/theme/theme.dart';
import 'package:postul/widgets/widgets.dart';

/// 📚 EXEMPLOS DE USO - Componentes Base
/// Este arquivo demonstra como usar todos os componentes

// ========== EXEMPLO 1: Tela de Login ==========
class ExemploTelaLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              label: "Email",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: AppSpacing.elementSpacing),
            CustomTextField(
              label: "Senha",
              prefixIcon: Icons.lock_outlined,
              suffixIcon: Icons.visibility_outlined,
              obscureText: true,
            ),
            SizedBox(height: AppSpacing.space24),
            PrimaryButton(
              label: "Entrar",
              icon: Icons.login,
              onPressed: () {},
              width: double.infinity,
            ),
            SizedBox(height: AppSpacing.space12),
            CustomTextButton(
              label: "Esqueci minha senha",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ========== EXEMPLO 2: Lista de Postos ==========
class ExemploListaPostos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Postos Próximos"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        itemCount: 10,
        itemBuilder: (context, index) {
          return PostoCard(
            nome: "Posto Shell ${index + 1}",
            endereco: "Av. Paulista, ${1000 + index * 100}",
            preco: 5.49 + (index * 0.10),
            distancia: 0.5 + (index * 0.3),
            avaliacao: 4.5,
            totalAvaliacoes: 234,
            combustiveis: ["Gasolina", "Etanol"],
            precoColor: index < 3
                ? AppColors.precoBaixo
                : index < 7
                    ? AppColors.precoMedio
                    : AppColors.precoAlto,
            onTap: () {
              _mostrarDetalhesPosto(context);
            },
          );
        },
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.filter_alt,
        onPressed: () {},
      ),
    );
  }

  void _mostrarDetalhesPosto(BuildContext context) {
    CustomBottomSheet.show(
      context,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.bottomSheetPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Posto Shell", style: AppTypography.titleLarge),
            SizedBox(height: AppSpacing.space8),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 16, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text("Av. Paulista, 1000", style: AppTypography.bodySmall),
              ],
            ),
            SizedBox(height: AppSpacing.space20),
            Text("Preços", style: AppTypography.titleMedium),
            SizedBox(height: AppSpacing.space12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PrecoCard(
                  tipoCombustivel: "Gasolina",
                  preco: 5.49,
                  cor: AppColors.gasolinaComum,
                  icon: Icons.local_gas_station,
                  isMelhorPreco: true,
                ),
                PrecoCard(
                  tipoCombustivel: "Etanol",
                  preco: 3.99,
                  cor: AppColors.etanol,
                  icon: Icons.eco,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space24),
            PrimaryButton(
              label: "Navegar até aqui",
              icon: Icons.navigation,
              onPressed: () {},
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

// ========== EXEMPLO 3: Favoritos ==========
class ExemploFavoritos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Favoritos"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        itemCount: 5,
        itemBuilder: (context, index) {
          return PostoFavoritoCard(
            nome: "Posto Shell ${index + 1}",
            endereco: "Av. Paulista, ${1000 + index * 100}",
            preco: 5.49,
            distancia: 2.5,
            combustivelPreferido: "Gasolina",
            onNavigate: () {
              CustomSnackbar.show(
                context,
                message: "Iniciando navegação...",
                type: SnackbarType.info,
              );
            },
            onRemove: () {
              CustomDialog.show(
                context,
                title: "Remover favorito?",
                description:
                    "Você tem certeza que deseja remover este posto dos favoritos?",
                icon: Icons.warning_outlined,
                actions: [
                  SecondaryButton(
                    label: "Cancelar",
                    onPressed: () => Navigator.pop(context),
                  ),
                  PrimaryButton(
                    label: "Remover",
                    onPressed: () {
                      Navigator.pop(context);
                      CustomSnackbar.show(
                        context,
                        message: "Favorito removido",
                        type: SnackbarType.success,
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ========== EXEMPLO 4: Filtros ==========
class ExemploFiltros extends StatefulWidget {
  @override
  _ExemploFiltrosState createState() => _ExemploFiltrosState();
}

class _ExemploFiltrosState extends State<ExemploFiltros> {
  String _combustivelSelecionado = "Gasolina Comum";
  double _raio = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filtros"),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Combustível", style: AppTypography.titleMedium),
            SizedBox(height: AppSpacing.space12),
            Wrap(
              spacing: AppSpacing.space8,
              runSpacing: AppSpacing.space8,
              children: [
                "Gasolina Comum",
                "Gasolina Aditivada",
                "Etanol",
                "Diesel"
              ]
                  .map(
                    (tipo) => CustomFilterChip(
                      label: tipo,
                      selected: _combustivelSelecionado == tipo,
                      avatar: Icons.local_gas_station,
                      onSelected: (selected) {
                        setState(() {
                          _combustivelSelecionado = tipo;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: AppSpacing.sectionSpacing),
            CustomSlider(
              label: "Raio de busca",
              value: _raio,
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _raio = value;
                });
              },
              labelFormatter: (v) => "${v.toInt()} km",
            ),
            Spacer(),
            PrimaryButton(
              label: "Aplicar Filtros",
              onPressed: () {
                Navigator.pop(context);
                CustomSnackbar.show(
                  context,
                  message: "Filtros aplicados com sucesso!",
                  type: SnackbarType.success,
                );
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

// ========== EXEMPLO 5: Avaliações ==========
class ExemploAvaliacoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Avaliações"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        itemCount: 10,
        itemBuilder: (context, index) {
          return AvaliacaoCard(
            nomeUsuario: "Usuário ${index + 1}",
            iniciais: "U${index + 1}",
            avaliacao: 4.5,
            comentario: index % 2 == 0
                ? "Ótimo posto, preço justo e bom atendimento!"
                : null,
            data: DateTime.now().subtract(Duration(days: index)),
          );
        },
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.rate_review,
        onPressed: () {
          CustomSnackbar.show(
            context,
            message: "Abrir tela de avaliação",
            type: SnackbarType.info,
          );
        },
      ),
    );
  }
}

// ========== EXEMPLO 6: Form de Atualizar Preço ==========
class ExemploAtualizarPreco extends StatefulWidget {
  @override
  _ExemploAtualizarPrecoState createState() => _ExemploAtualizarPrecoState();
}

class _ExemploAtualizarPrecoState extends State<ExemploAtualizarPreco> {
  String _combustivelSelecionado = "Gasolina Comum";
  final _precoController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Atualizar Preço"),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Posto Shell", style: AppTypography.titleLarge),
            SizedBox(height: AppSpacing.space8),
            Text(
              "Av. Paulista, 1000",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sectionSpacing),
            CustomDropdown<String>(
              label: "Tipo de Combustível",
              value: _combustivelSelecionado,
              prefixIcon: Icons.local_gas_station,
              items: [
                "Gasolina Comum",
                "Gasolina Aditivada",
                "Etanol",
                "Diesel"
              ]
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _combustivelSelecionado = value!;
                });
              },
            ),
            SizedBox(height: AppSpacing.elementSpacing),
            CustomTextField(
              label: "Preço (R\$)",
              controller: _precoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.attach_money,
              hintText: "Ex: 5.89",
            ),
            Spacer(),
            PrimaryButton(
              label: "Atualizar Preço",
              icon: Icons.check,
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() {
                        _loading = true;
                      });

                      // Simular delay
                      await Future.delayed(Duration(seconds: 2));

                      setState(() {
                        _loading = false;
                      });

                      CustomSnackbar.show(
                        context,
                        message: "Preço atualizado com sucesso!",
                        type: SnackbarType.success,
                      );

                      Navigator.pop(context);
                    },
              width: double.infinity,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
