const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const { exec } = require('child_process');
const path = require('path');

// Função para verificar a assinatura do GitHub
function verifyGitHubSignature(req, secret) {
    const signature = req.headers['x-hub-signature-256'];
    if (!signature) {
        return false;
    }

    const hmac = crypto.createHmac('sha256', secret);
    const digest = 'sha256=' + hmac.update(JSON.stringify(req.body)).digest('hex');
    
    return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(digest));
}

// Endpoint para receber webhooks do GitHub
router.post('/github', async (req, res) => {
    console.log('Webhook recebido do GitHub');

    // Verificar se é um evento de push
    const event = req.headers['x-github-event'];
    if (event !== 'push') {
        console.log(`Evento ignorado: ${event}`);
        return res.status(200).json({ message: 'Evento ignorado' });
    }

    // Verificar assinatura (se WEBHOOK_SECRET estiver definido)
    const secret = process.env.WEBHOOK_SECRET;
    if (secret) {
        if (!verifyGitHubSignature(req, secret)) {
            console.error('Assinatura inválida!');
            return res.status(401).json({ error: 'Assinatura inválida' });
        }
    } else {
        console.warn('ATENÇÃO: WEBHOOK_SECRET não configurado - qualquer um pode acionar o deploy!');
    }

    // Verificar se o push foi na branch main
    const branch = req.body.ref;
    if (branch !== 'refs/heads/main') {
        console.log(`Push ignorado - branch: ${branch}`);
        return res.status(200).json({ message: 'Branch ignorado' });
    }

    console.log('Push detectado na branch main - iniciando atualização...');

    // Responder imediatamente ao GitHub
    res.status(200).json({ 
        message: 'Webhook recebido - atualização iniciada',
        timestamp: new Date().toISOString()
    });

    // Executar o script de atualização em background
    const scriptPath = path.join(__dirname, '..', '..', 'auto-deploy.bat');
    
    exec(`"${scriptPath}"`, { cwd: path.join(__dirname, '..', '..') }, (error, stdout, stderr) => {
        if (error) {
            console.error(`Erro ao executar auto-deploy: ${error.message}`);
            return;
        }
        if (stderr) {
            console.error(`Stderr: ${stderr}`);
        }
        console.log(`Atualização concluída:\n${stdout}`);
    });
});

// Endpoint para testar manualmente
router.get('/test', (req, res) => {
    res.json({ 
        message: 'Webhook endpoint está funcionando',
        timestamp: new Date().toISOString()
    });
});

module.exports = router;
