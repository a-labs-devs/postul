import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// ⛽ Tipos de Combustível
enum TipoCombustivel {
  gasolinaComum,
  gasolinaAditivada,
  etanol,
  diesel,
  gnv,
}

extension TipoCombustivelExtension on TipoCombustivel {
  String get nome {
    switch (this) {
      case TipoCombustivel.gasolinaComum:
        return 'Gasolina Comum';
      case TipoCombustivel.gasolinaAditivada:
        return 'Gasolina Aditivada';
      case TipoCombustivel.etanol:
        return 'Etanol';
      case TipoCombustivel.diesel:
        return 'Diesel';
      case TipoCombustivel.gnv:
        return 'GNV';
    }
  }

  String get nomeAbreviado {
    switch (this) {
      case TipoCombustivel.gasolinaComum:
        return 'Gasolina';
      case TipoCombustivel.gasolinaAditivada:
        return 'G. Aditivada';
      case TipoCombustivel.etanol:
        return 'Etanol';
      case TipoCombustivel.diesel:
        return 'Diesel';
      case TipoCombustivel.gnv:
        return 'GNV';
    }
  }

  Color get cor {
    switch (this) {
      case TipoCombustivel.gasolinaComum:
        return AppColors.gasolinaComum;
      case TipoCombustivel.gasolinaAditivada:
        return AppColors.gasolinaAditivada;
      case TipoCombustivel.etanol:
        return AppColors.etanol;
      case TipoCombustivel.diesel:
        return AppColors.diesel;
      case TipoCombustivel.gnv:
        return AppColors.gnv;
    }
  }

  IconData get icon {
    switch (this) {
      case TipoCombustivel.etanol:
        return Icons.eco;
      case TipoCombustivel.diesel:
        return Icons.local_shipping;
      case TipoCombustivel.gnv:
        return Icons.cloud;
      default:
        return Icons.local_gas_station;
    }
  }
}

/// 📊 Tipo de Ordenação
enum OrdenacaoTipo {
  distancia,
  preco,
  custoBeneficio,
  tempo,
  avaliacao,
}

extension OrdenacaoTipoExtension on OrdenacaoTipo {
  String get nome {
    switch (this) {
      case OrdenacaoTipo.distancia:
        return 'Menor distância';
      case OrdenacaoTipo.preco:
        return 'Menor preço';
      case OrdenacaoTipo.custoBeneficio:
        return 'Melhor custo-benefício';
      case OrdenacaoTipo.tempo:
        return 'Menor tempo';
      case OrdenacaoTipo.avaliacao:
        return 'Melhor avaliação';
    }
  }

  IconData get icon {
    switch (this) {
      case OrdenacaoTipo.distancia:
        return Icons.straighten;
      case OrdenacaoTipo.preco:
        return Icons.attach_money;
      case OrdenacaoTipo.custoBeneficio:
        return Icons.trending_up;
      case OrdenacaoTipo.tempo:
        return Icons.schedule;
      case OrdenacaoTipo.avaliacao:
        return Icons.star;
    }
  }
}
