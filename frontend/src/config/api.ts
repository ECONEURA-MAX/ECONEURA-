/**
 * ECONEURA - API Configuration
 * Centralized API URL and correlation ID generation
 */

const getApiUrl = () => {
  // FORZAR puerto 8080 para desarrollo local
  return 'http://localhost:8080/api';
};

export const API_URL = getApiUrl();

export function generateCorrelationId(prefix = 'web'): string {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

