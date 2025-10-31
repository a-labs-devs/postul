import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/posto.dart';
import '../../models/tipos_combustivel.dart';
import 'posto_detail_bottom_sheet.dart';

/// 📋 POSTUL - Tela de Lista de Postos
class ListaPostosScreen extends StatefulWidget {
  const ListaPostosScreen({Key? key}) : super(key: key);

  @override
  State<ListaPostosScreen> createState() => _ListaPostosScreenState();
}

class _ListaPostosScreenState extends State<ListaPostosScreen> {
  List<Posto> _postos = [];
  bool _isLoading = true;
  OrdenacaoTipo _ordenacaoAtual = OrdenacaoTipo.distancia;
  TipoCombustivel? _filtroAtivo;
  double _raioKm = 5.0;

  @override
  void initState() {
    super.initState();
    _carregarPostos();
  }

  Future<void> _carregarPostos() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Dados mockados
    setState(() {
      _postos = [
        Posto(
          id: 1,
          nome: 'Posto Shell Centro',
          endereco: 'Av. Paulista, 1000',
          latitude: -23.5505,
          longitude: -46.6333,
          aberto24h: true,
          precos: null,
          distancia: 0.5,
        ),
        Posto(
          id: 2,
          nome: 'Posto Ipiranga Norte',
          endereco: 'Av. Rebouças, 2500',
          latitude: -23.5555,
          longitude: -46.6383,
          aberto24h: false,
          precos: null,
          distancia: 1.2,
        ),
        Posto(
          id: 3,
          nome: 'Posto BR Sul',
          endereco: 'Av. Brigadeiro Luís Antônio, 800',
          latitude: -23.5455,
          longitude: -46.6283,
          aberto24h: true,
          precos: null,
          distancia: 0.8,
        ),
        Posto(
          id: 4,
          nome: 'Posto Petrobras Oeste',
          endereco: 'Av. Faria Lima, 1500',
          latitude: -23.5705,
          longitude: -46.6933,
          aberto24h: false,
          precos: null,
          distancia: 2.3,
        ),
      ];
      _isLoading = false;
    });
  }

  void _ordenarPor(OrdenacaoTipo tipo) {
    setState(() {
      _ordenacaoAtual = tipo;
      // TODO: Implementar lógica de ordenação
      switch (tipo) {
        case OrdenacaoTipo.distancia:
          _postos.sort((a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0));
          break;
        case OrdenacaoTipo.preco:
          // Ordenar por preço quando implementado
          break;
        case OrdenacaoTipo.avaliacao:
          // Ordenar por avaliação quando implementado
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primaryDark,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              "Postos Próximos",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
          // Botão de Pesquisa
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PostoSearchDelegate(_postos),
              );
            },
            tooltip: 'Pesquisar posto',
          ),
          // Menu de Ordenação
          PopupMenuButton<OrdenacaoTipo>(
            icon: const Icon(Icons.sort),
            onSelected: _ordenarPor,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: OrdenacaoTipo.distancia,
                child: Row(
                  children: [
                    Icon(OrdenacaoTipo.distancia.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(OrdenacaoTipo.distancia.nome),
                  ],
                ),
              ),
              PopupMenuItem(
                value: OrdenacaoTipo.preco,
                child: Row(
                  children: [
                    Icon(OrdenacaoTipo.preco.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(OrdenacaoTipo.preco.nome),
                  ],
                ),
              ),
              PopupMenuItem(
                value: OrdenacaoTipo.custoBeneficio,
                child: Row(
                  children: [
                    Icon(OrdenacaoTipo.custoBeneficio.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(OrdenacaoTipo.custoBeneficio.nome),
                  ],
                ),
              ),
              PopupMenuItem(
                value: OrdenacaoTipo.tempo,
                child: Row(
                  children: [
                    Icon(OrdenacaoTipo.tempo.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(OrdenacaoTipo.tempo.nome),
                  ],
                ),
              ),
              PopupMenuItem(
                value: OrdenacaoTipo.avaliacao,
                child: Row(
                  children: [
                    Icon(OrdenacaoTipo.avaliacao.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(OrdenacaoTipo.avaliacao.nome),
                  ],
                ),
              ),
            ],
          ),
        ],
          ),
        ),
      ),
      body: Column(
        children: [
          // FILTROS
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CustomFilterChip(
                  label: "Gasolina",
                  selected: _filtroAtivo == TipoCombustivel.gasolinaComum,
                  avatar: Icons.local_gas_station,
                  onSelected: (s) => setState(() => _filtroAtivo =
                      s ? TipoCombustivel.gasolinaComum : null),
                ),
                SizedBox(width: AppSpacing.space8),
                CustomFilterChip(
                  label: "Etanol",
                  selected: _filtroAtivo == TipoCombustivel.etanol,
                  avatar: Icons.eco,
                  onSelected: (s) => setState(() => _filtroAtivo =
                      s ? TipoCombustivel.etanol : null),
                ),
                SizedBox(width: AppSpacing.space8),
                CustomFilterChip(
                  label: "Diesel",
                  selected: _filtroAtivo == TipoCombustivel.diesel,
                  avatar: Icons.local_shipping,
                  onSelected: (s) => setState(() => _filtroAtivo =
                      s ? TipoCombustivel.diesel : null),
                ),
                SizedBox(width: AppSpacing.space8),
                ActionChip(
                  label: Text("$_raioKm km"),
                  avatar: const Icon(Icons.radio_button_checked, size: 18),
                  onPressed: () {
                    // TODO: Mostrar slider de raio
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // LISTA
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _postos.isEmpty
                    ? _buildEstadoVazio()
                    : RefreshIndicator(
                        onRefresh: _carregarPostos,
                        child: ListView.builder(
                          padding: EdgeInsets.all(AppSpacing.space16),
                          itemCount: _postos.length,
                          itemBuilder: (context, index) {
                            final posto = _postos[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: AppSpacing.space12,
                              ),
                              child: PostoCard(
                                nome: posto.nome,
                                endereco: posto.endereco,
                                preco: 5.49, // Mockado
                                distancia: posto.distancia ?? 0,
                                avaliacao: 4.5, // Mockado
                                totalAvaliacoes: 120, // Mockado
                                combustiveis: const [
                                  'Gasolina',
                                  'Etanol',
                                  'Diesel'
                                ],
                                precoColor: AppColors.precoBaixo,
                                onTap: () => _showPostoDetail(posto),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.space24),
            Text(
              'Nenhum posto encontrado',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.space8),
            Text(
              'Tente aumentar o raio de busca ou\nmudar o filtro de combustível',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space32),
            PrimaryButton(
              label: "Ajustar filtros",
              onPressed: () {
                // TODO: Abrir filtros
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPostoDetail(Posto posto) {
    CustomBottomSheet.show(
      context,
      child: PostoDetailBottomSheet(posto: posto),
    );
  }
}

/// 🔍 Search Delegate para busca de postos
class _PostoSearchDelegate extends SearchDelegate<Posto?> {
  final List<Posto> postos;

  _PostoSearchDelegate(this.postos);

  @override
  String get searchFieldLabel => 'Buscar posto...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = postos.where((posto) {
      final searchLower = query.toLowerCase();
      final nomeLower = posto.nome.toLowerCase();
      final enderecoLower = posto.endereco.toLowerCase();
      return nomeLower.contains(searchLower) || enderecoLower.contains(searchLower);
    }).toList();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.space16),
            Text(
              'Digite o nome do posto\nou endereço',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.space16),
            Text(
              'Nenhum posto encontrado',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final posto = results[index];
        return PostoCard(
          nome: posto.nome,
          endereco: posto.endereco,
          preco: 5.49,
          distancia: posto.distancia ?? 0,
          avaliacao: 4.5,
          totalAvaliacoes: 120,
          combustiveis: ['Gasolina', 'Etanol', 'Diesel'],
          precoColor: AppColors.success,
          onTap: () {
            close(context, posto);
            // Navegar para detalhes ou abrir modal
          },
        );
      },
    );
  }
}
