// Configuracao centralizada da API
// Este arquivo centraliza as URLs da API para facilitar manutencao

// URL base da API
const BASE_API_URL = 'http://[VServidor]:[VPorta]'
//const BASE_API_URL = 'http://192.168.1.100:9000'

// Endpoint de Login
export const LOGIN_ENDPOINT = `${BASE_API_URL}/login`

// Endpoints da API - apenas os que existem atualmente
export const API_ENDPOINTS = {
  // Modulo de Refis
  refis: {
    list: `${BASE_API_URL}/cliente/refis`
  },

  // Modulo de Clientes
  clientes: {
    listar: (filtros = {}) => {
      const params = new URLSearchParams()
      if (filtros.codigo) params.append('codigo', filtros.codigo)
      if (filtros.nome) params.append('nome', filtros.nome)
      if (filtros.numero) params.append('numero', filtros.numero)
      if (filtros.cpfcnpj) params.append('cpfcnpj', filtros.cpfcnpj)
      const queryString = params.toString()
      return `${BASE_API_URL}/cliente${queryString ? '?' + queryString : ''}`
    },
    proximosVencer: `${BASE_API_URL}/cliente/proximo`,
    buscarPorTelefone: (telefone) => `${BASE_API_URL}/cliente/proximo/${telefone}`,
    atualizar: `${BASE_API_URL}/cliente`,
    checkWhatsApp: (id) => `${BASE_API_URL}/cliente/check/${id}`,
    verificarNumero: (numero) => `${BASE_API_URL}/cliente/check_numero/${numero}`
  },

  // Modulo de Vendas
  vendas: {
    mensal: (inicio, fim) => `${BASE_API_URL}/vendas/mensal?inicio=${inicio}&fim=${fim}`,
    resumo: `${BASE_API_URL}/vendas/resumo`,
    produtosMaisVendidos: (inicio, fim) => `${BASE_API_URL}/vendas/produto-mais-vendido?inicio=${inicio}&fim=${fim}`
  },

  // Modulo de Ordens de Servico
  os: {
    abertas: `${BASE_API_URL}/os/abertas`,
    atualizarSituacao: `${BASE_API_URL}/os/situacao`
  },

  // Modulo de Historico de Conversas (Evolution API)
  historico: {
    buscar: `${BASE_API_URL}/chat/historico`
  },

  // Modulo de Cron (Lembretes WhatsApp)
  cron: {
    config: `${BASE_API_URL}/cron/config`,
    status: `${BASE_API_URL}/cron/status`,
    execute: `${BASE_API_URL}/cron/execute`,
    pause: `${BASE_API_URL}/cron/pause`,
    resume: `${BASE_API_URL}/cron/resume`,
    stop: `${BASE_API_URL}/cron/stop`,
    start: `${BASE_API_URL}/cron/start`
  },

  // Modulo de Credenciais (Tecnico, Chat, WhatsApp)
  credenciais: {
    get: `${BASE_API_URL}/credenciais`,
    update: `${BASE_API_URL}/credenciais`
  },

  // Modulo de Evolution API (WhatsApp)
  evolution: {
    state: `${BASE_API_URL}/evolution/state`,
    connect: `${BASE_API_URL}/evolution/connect`,
    logout: `${BASE_API_URL}/evolution/logout`
  }
}

// Configuracoes globais da API
export const API_CONFIG = {
  timeout: 20000,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json'
  }
}

// Funcao helper para configurar Axios
export const getAxiosConfig = () => ({
  timeout: API_CONFIG.timeout,
  headers: API_CONFIG.headers
})
