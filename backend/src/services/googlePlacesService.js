const { Client } = require('@googlemaps/google-maps-services-js');
const pool = require('../config/database');

const client = new Client({});
const API_KEY = process.env.GOOGLE_PLACES_API_KEY;

const googlePlacesService = {
    // Buscar postos de gasolina em uma região
    buscarPostosNaRegiao: async (latitude, longitude, raio = 5000) => {
        try {
            const response = await client.placesNearby({
                params: {
                    location: { lat: latitude, lng: longitude },
                    radius: raio, // em metros
                    type: 'gas_station',
                    key: API_KEY,
                },
            });

            return response.data.results;
        } catch (error) {
            console.error('Erro ao buscar postos no Google Places:', error);
            throw error;
        }
    },

    // Obter detalhes completos de um posto
    obterDetalhesPosto: async (placeId) => {
        try {
            const response = await client.placeDetails({
                params: {
                    place_id: placeId,
                    fields: ['name', 'formatted_address', 'geometry', 'formatted_phone_number', 'opening_hours'],
                    key: API_KEY,
                },
            });

            return response.data.result;
        } catch (error) {
            console.error('Erro ao obter detalhes do posto:', error);
            throw error;
        }
    },

    // Importar postos para o banco de dados
    importarPostosParaBanco: async (latitude, longitude, raio = 5000) => {
        try {
            console.log(`🔍 Buscando postos próximos a ${latitude}, ${longitude}...`);

            const postos = await googlePlacesService.buscarPostosNaRegiao(latitude, longitude, raio);

            console.log(`✅ Encontrados ${postos.length} postos no Google Places`);

            let importados = 0;
            let jaExistentes = 0;
            let erros = 0;

            for (const posto of postos) {
                try {
                    // Verificar se posto já existe no banco
                    const existe = await pool.query(
                        'SELECT id FROM postos WHERE latitude = $1 AND longitude = $2',
                        [posto.geometry.location.lat, posto.geometry.location.lng]
                    );

                    if (existe.rows.length > 0) {
                        jaExistentes++;
                        console.log(`⚠️  Posto já existe: ${posto.name}`);
                        continue;
                    }

                    // Obter detalhes completos
                    console.log(`📍 Buscando detalhes de: ${posto.name}`);
                    const detalhes = await googlePlacesService.obterDetalhesPosto(posto.place_id);

                    // Inserir no banco
                    await pool.query(
                        `INSERT INTO postos (nome, endereco, latitude, longitude, telefone, aberto_24h)
             VALUES ($1, $2, $3, $4, $5, $6)`,
                        [
                            detalhes.name || posto.name,
                            detalhes.formatted_address || posto.vicinity,
                            posto.geometry.location.lat,
                            posto.geometry.location.lng,
                            detalhes.formatted_phone_number || null,
                            detalhes.opening_hours?.open_now || false
                        ]
                    );

                    importados++;
                    console.log(`✅ Importado: ${posto.name}`);

                    // Aguardar 200ms entre requisições para não exceder limites
                    await new Promise(resolve => setTimeout(resolve, 200));

                } catch (erroIndividual) {
                    erros++;
                    console.error(`❌ Erro ao importar ${posto.name}:`, erroIndividual.message);
                    // Continua para o próximo posto mesmo se der erro
                }
            }

            return {
                total: postos.length,
                importados,
                jaExistentes,
                erros
            };

        } catch (error) {
            console.error('❌ Erro ao importar postos:', error.message);

            // Verificar se é erro de billing
            if (error.message.includes('403') || error.message.includes('BILLING')) {
                throw new Error('Conta de faturamento do Google Cloud ainda não está ativa. Aguarde 24-48h e tente novamente.');
            }

            throw error;
        }
    }
};

module.exports = googlePlacesService;