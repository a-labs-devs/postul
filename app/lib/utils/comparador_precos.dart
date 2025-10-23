import '../models/posto.dart';

class ComparadorPrecos {
  // Encontrar posto com menor preço de um tipo de combustível
  static Posto? encontrarMaisBarato(List<Posto> postos, String tipoCombustivel) {
    if (postos.isEmpty) return null;
    
    Posto? maisBarato;
    double? menorPreco;
    
    for (var posto in postos) {
      final preco = posto.getMenorPreco(tipoCombustivel);
      if (preco != null) {
        if (menorPreco == null || preco < menorPreco) {
          menorPreco = preco;
          maisBarato = posto;
        }
      }
    }
    
    return maisBarato;
  }
  
  // Calcular economia comparado ao posto mais barato
  static double? calcularEconomia(Posto posto, Posto? postoMaisBarato, String tipoCombustivel) {
    if (postoMaisBarato == null) return null;
    
    final precoAtual = posto.getMenorPreco(tipoCombustivel);
    final precoMaisBarato = postoMaisBarato.getMenorPreco(tipoCombustivel);
    
    if (precoAtual == null || precoMaisBarato == null) return null;
    
    return precoAtual - precoMaisBarato;
  }
  
  // Obter níveis de preço (mais barato, médio, caro)
  static String getNivelPreco(Posto posto, List<Posto> postos, String tipoCombustivel) {
    final maisBarato = encontrarMaisBarato(postos, tipoCombustivel);
    final economia = calcularEconomia(posto, maisBarato, tipoCombustivel);
    
    if (economia == null) return 'Sem dados';
    if (economia == 0) return 'Melhor preço';
    if (economia <= 0.10) return 'Preço bom';
    if (economia <= 0.20) return 'Preço médio';
    return 'Preço alto';
  }
}