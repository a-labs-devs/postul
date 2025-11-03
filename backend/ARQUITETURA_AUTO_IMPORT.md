# 🤖 Arquitetura de Auto-Importação de Postos

## ✅ O Que Foi Implementado

### 1. **Serviço de Auto-Importação** (`src/services/autoImportService.js`)
- **Importação automática na inicialização** do servidor
- **Importação sob demanda** quando usuário não encontra postos
- **USA APENAS APIs REAIS** - Google Places API
- **SEM DADOS MOCKADOS** - Todos os dados vêm de fontes reais

### 2. **Como Funciona**

#### Na Inicialização do Servidor:
```
1. Servidor inicia (alabsv.ddns.net:3001)
2. Verifica se banco tem menos de 10 postos
3. Se sim → Importa automaticamente de pontos estratégicos
4. Usa Google Places API para buscar postos reais
```

#### Quando Usuário Busca Postos:
```
1. App busca postos na área do usuário
2. Se encontrar 0 postos → Ativa auto-importação
3. Importa postos da Google Places API naquela região
4. Retorna os postos recém-importados
```

### 3. **APIs Utilizadas (APENAS REAIS)**

#### ✅ Google Places API (PRINCIPAL)
- **Endpoint**: `https://places.googleapis.com/v1/places:searchNearby`
- **Função**: Busca postos de gasolina reais por geolocalização
- **Chave**: `GOOGLE_PLACES_API_KEY` no `.env`
- **Retorna**: Nome, endereço, coordenadas, telefone, horários

#### ✅ ANP (Agência Nacional do Petróleo) - OPCIONAL
- **Arquivo**: `importar_precos_anp.js`
- **Função**: Importa preços reais de combustíveis
- **Fonte**: Dados oficiais do governo brasileiro
- **Formato**: CSV baixado de https://www.gov.br/anp

### 4. **Fluxo de Dados**

```
┌─────────────────────┐
│   Banco Vazio ou    │
│   Busca sem Result. │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  autoImportService  │
│    .importar()      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Google Places API  │
│   (Dados Reais)     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  PostgreSQL         │
│  Tabela: postos     │
└─────────────────────┘
```

### 5. **Arquivos e Responsabilidades**

| Arquivo | Tipo | Função |
|---------|------|--------|
| `src/services/autoImportService.js` | **CORE** | Serviço principal de auto-importação |
| `src/server.js` | **CORE** | Inicia auto-importação no startup |
| `src/controllers/postosController.js` | **CORE** | Busca com fallback para auto-importação |
| `importar_postos_google.js` | Script CLI | Importação manual (caso necessário) |
| `importar_precos_anp.js` | Script CLI | Importa preços da ANP (opcional) |
| ~~`gerar_precos_teste.js`~~ | ❌ DELETADO | Era mock, foi removido |

### 6. **Configuração Necessária**

No arquivo `.env`, certifique-se de ter:

```env
# Google Places API (OBRIGATÓRIO)
GOOGLE_PLACES_API_KEY=AIzaSy...

# Banco de Dados PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=admin123
DB_NAME=postos_db
```

### 7. **CI/CD via GitHub Webhook**

Quando você faz push para o repositório:
```
1. GitHub → Webhook → alabsv.ddns.net
2. Servidor puxa código atualizado
3. Reinicia automaticamente
4. Auto-importação executa se banco estiver vazio
5. App volta a funcionar com postos reais
```

### 8. **Garantias de Qualidade**

✅ **Sem Mock**: Nenhum dado fictício é usado  
✅ **Sem Hardcode**: Todos os postos vêm de APIs  
✅ **Automático**: Sistema se auto-popula  
✅ **Resiliente**: Funciona mesmo com banco vazio  
✅ **Incremental**: Não duplica postos já existentes  

### 9. **Logs e Monitoramento**

O sistema exibe logs claros:

```
🚀 Servidor rodando na porta 3001
📊 Total de postos no banco: 0
🚀 Banco vazio ou com poucos postos. Iniciando importação...

🔍 Buscando postos em Centro SP...
✅ 1. Posto Ipiranga - Av Paulista
✅ 2. Shell Select - Consolação
...

✅ ========== IMPORTAÇÃO CONCLUÍDA ==========
📊 Total importados: 87
```

### 10. **Como Testar Localmente**

```bash
# 1. Parar o servidor
Ctrl+C

# 2. Limpar a tabela de postos
psql -U admin -d postos_db
DELETE FROM postos;
\q

# 3. Reiniciar o servidor
cd backend
node src/server.js

# 4. Observar os logs de auto-importação
# Deve mostrar o processo de importação automaticamente
```

### 11. **Troubleshooting**

| Problema | Solução |
|----------|---------|
| "GOOGLE_API_KEY não configurada" | Adicionar `GOOGLE_PLACES_API_KEY` no `.env` |
| "Nenhum posto encontrado" | Verificar se API key está válida |
| "Erro ao conectar banco" | Verificar se PostgreSQL está rodando |
| "0 postos importados" | Verificar quota da Google Places API |

### 12. **Diferença dos Arquivos**

#### `src/services/autoImportService.js` (NOVO - PRODUÇÃO)
- ✅ Roda automaticamente no servidor
- ✅ Integrado com o sistema
- ✅ Usado pelo controller de postos
- ✅ Trata casos de banco vazio e buscas sem resultado

#### `importar_postos_google.js` (ANTIGO - SCRIPT MANUAL)
- ⚠️ Precisa ser executado manualmente: `node importar_postos_google.js`
- ⚠️ Não está integrado ao fluxo automático
- ⚠️ Usado apenas para importações massivas manuais
- ✅ Também usa apenas Google Places API (sem mock)

## 🎯 Conclusão

O sistema agora é **100% baseado em APIs reais**:
- ✅ Google Places API para postos
- ✅ ANP para preços (opcional)
- ❌ Zero dados mockados/teste
- ✅ Auto-importação inteligente
- ✅ Funciona com CI/CD via webhook
