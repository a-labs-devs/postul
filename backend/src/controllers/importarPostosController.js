const googlePlacesService = require('../services/googlePlacesService');

const importarPostosController = {
  // Importar postos de uma região específica
  importarPorRegiao: async (req, res) => {
    const { latitude, longitude, raio } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Latitude e longitude são obrigatórios'
      });
    }

    const raioMetros = raio ? raio * 1000 : 5000; // Converter km para metros

    try {
      console.log('🚀 Iniciando importação de postos...');
      
      const resultado = await googlePlacesService.importarPostosParaBanco(
        latitude,
        longitude,
        raioMetros
      );

      res.json({
        sucesso: true,
        mensagem: 'Importação concluída',
        resultado: {
          total_encontrados: resultado.total,
          novos_importados: resultado.importados,
          ja_existentes: resultado.jaExistentes
        }
      });

    } catch (error) {
      console.error('Erro na importação:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao importar postos',
        erro: error.message
      });
    }
  }
};

module.exports = importarPostosController;