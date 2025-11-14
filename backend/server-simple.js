// ECONEURA Backend - VERSIÓN SIMPLE PARA PRUEBA
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// CORS simple
app.use(cors({
  origin: 'http://localhost:5173',
  credentials: true
}));

// Body parser
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    port: PORT,
    message: 'ECONEURA Backend Simple - Running'
  });
});

// Mock login endpoint
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  if (email === 'test@econeura.com' && password === 'mock') {
    res.json({
      success: true,
      token: 'mock-jwt-token-' + Date.now(),
      user: {
        id: 1,
        email: 'test@econeura.com',
        name: 'Test User',
        role: 'admin'
      }
    });
  } else {
    res.status(401).json({
      success: false,
      message: 'Credenciales inválidas'
    });
  }
});

// Mock chat endpoint
app.post('/api/chat', (req, res) => {
  const { message } = req.body;
  
  res.json({
    response: `Echo: ${message}`,
    timestamp: new Date().toISOString()
  });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log('\n' + '='.repeat(60));
  console.log(`✅ ECONEURA Backend Simple - RUNNING`);
  console.log(`🌐 Server: http://localhost:${PORT}`);
  console.log(`📊 Health: http://localhost:${PORT}/api/health`);
  console.log('='.repeat(60) + '\n');
});

