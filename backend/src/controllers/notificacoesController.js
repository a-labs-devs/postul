const messaging = require('../config/firebase');

const notificacoesController = {
  // Enviar notificação de teste
  enviarTeste: async (req, res) => {
    const { token, titulo, corpo } = req.body;

    if (!token) {
      return res.status(400).json({
        sucesso: false,
        mensagem: 'Token FCM é obrigatório'
      });
    }

    const message = {
      notification: {
        title: titulo || 'Teste de Notificação',
        body: corpo || 'Esta é uma notificação de teste do Postul!'
      },
      token: token
    };

    try {
      const response = await messaging.send(message);
      console.log('✅ Notificação enviada com sucesso:', response);

      res.json({
        sucesso: true,
        mensagem: 'Notificação enviada com sucesso',
        messageId: response
      });
    } catch (error) {
      console.error('❌ Erro ao enviar notificação:', error);
      res.status(500).json({
        sucesso: false,
        mensagem: 'Erro ao enviar notificação',
        erro: error.message
      });
    }
  },

  // Notificar sobre atualização de preço
  notificarPrecoAtualizado: async (token, nomePosto, combustivel, preco) => {
    const message = {
      notification: {
        title: '💰 Preço Atualizado!',
        body: `${nomePosto}: ${combustivel} por R$ ${preco.toFixed(2)}`
      },
      token: token
    };

    try {
      await messaging.send(message);
      console.log('✅ Notificação de preço enviada');
    } catch (error) {
      console.error('❌ Erro ao enviar notificação:', error);
    }
  },

  // Notificar novo posto próximo
  notificarNovoPostoProximo: async (token, nomePosto, distancia) => {
    const message = {
      notification: {
        title: '⛽ Novo Posto Próximo!',
        body: `${nomePosto} a ${distancia.toFixed(1)} km de você`
      },
      token: token
    };

    try {
      await messaging.send(message);
      console.log('✅ Notificação de novo posto enviada');
    } catch (error) {
      console.error('❌ Erro ao enviar notificação:', error);
    }
  }
};

module.exports = notificacoesController;