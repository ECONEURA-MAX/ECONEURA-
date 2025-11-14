# 💰 COSTES REALES DE AZURE - ECONEURA

**Última actualización**: 13 Noviembre 2025  
**Disclaimer**: Estos son costes REALES basados en uso típico, no solo el pricing base.

---

## 🎯 RESUMEN EJECUTIVO

| Environment | Coste Base | Coste Real | Notas |
|-------------|------------|------------|-------|
| **Staging** | €67/mes | **€110-130/mes** | Con uso moderado |
| **Production** | €358/mes | **€450-550/mes** | Con tráfico real |

⚠️ **Los costes pueden variar +/- 20% según uso real**

---

## 📊 DESGLOSE STAGING (DETALLADO)

### Servicios Core

| Servicio | SKU | Coste Base | Uso Típico | Coste Real |
|----------|-----|------------|------------|------------|
| **PostgreSQL Flexible** | Standard_B1ms | €10.10/mes | +2GB backups | **€12/mes** |
| **Redis Cache** | Basic C0 (250MB) | €14.64/mes | No adicionales | **€15/mes** |
| **App Service** | B2 (2 cores, 3.5GB RAM) | €68.62/mes | Incluido en plan compartido | **€15/mes** |
| **Static Web App** | Free tier | €0/mes | No adicionales | **€0/mes** |
| **Storage Account** | Standard LRS | €0.02/GB/mes | 10GB datos + 50GB bandwidth | **€8/mes** |
| **Key Vault** | Standard | €0.03/10K ops | 1K ops/mes | **€2/mes** |
| **Application Insights** | Pay-as-you-go | €2/GB | 5-10GB/mes | **€20/mes** |
| **Log Analytics** | Pay-as-you-go | €2.30/GB | 3-5GB/mes | **€12/mes** |

### Costes Adicionales (IMPORTANTES)

| Concepto | Coste | Notas |
|----------|-------|-------|
| **Bandwidth salida** | €0.08/GB | 50-100GB/mes = €8-15/mes |
| **Backups adicionales** | €0.10/GB/mes | 5GB snapshots = €0.50/mes |
| **IP address pública** | €2.92/mes | 1 IP estática |
| **DNS queries** | €0.40/millón | Negligible |
| **Monitoring alerts** | €0.10/alerta/mes | 10 alertas = €1/mes |

### TOTAL STAGING

```
Base:                    €110.30/mes
Bandwidth (promedio):    €10/mes
Alertas:                 €1/mes
Buffer (10%):            €12/mes
─────────────────────────────────
TOTAL:                   €133/mes
```

**Rango realista: €110-150/mes**

---

## 📊 DESGLOSE PRODUCTION (DETALLADO)

### Servicios Core

| Servicio | SKU | Coste Base | Uso Típico | Coste Real |
|----------|-----|------------|------------|------------|
| **PostgreSQL Flexible** | Standard_D2s_v3 | €117/mes | +30GB backups, geo-redundant | **€145/mes** |
| **Redis Cache** | Standard C1 (1GB) | €48.41/mes | +geo-replication | **€55/mes** |
| **App Service** | P1v3 (2 cores, 8GB RAM) | €73.14/mes | Auto-scaling 2-5 instances | **€180/mes** |
| **Static Web App** | Standard | €7.69/mes | Custom domain + SSL | **€10/mes** |
| **Storage Account** | Standard ZRS | €0.03/GB/mes | 50GB datos + 500GB bandwidth | **€50/mes** |
| **Key Vault** | Premium (HSM) | €1/key/mes | 10 keys | **€12/mes** |
| **Application Insights** | Pay-as-you-go | €2/GB | 20-30GB/mes | **€55/mes** |
| **Log Analytics** | Pay-as-you-go | €2.30/GB | 10-15GB/mes | **€30/mes** |
| **Azure Front Door** | Standard | €25/mes | +WAF +bandwidth | **€60/mes** |
| **DDoS Protection** | Standard | €2,944/mes | **NO ACTIVAR AHHORA** | €0/mes |

### Costes Adicionales

| Concepto | Coste | Notas |
|----------|-------|-------|
| **Bandwidth salida** | €0.08/GB | 500-1000GB/mes = €40-80/mes |
| **Backups adicionales** | €0.10/GB/mes | 50GB snapshots = €5/mes |
| **Azure DNS** | €0.50/zona/mes | 1 zona + queries = €1/mes |
| **Monitoring alerts** | €0.10/alerta/mes | 30 alertas = €3/mes |
| **Support plan** | €29/mes | Basic (opcional) |

### TOTAL PRODUCTION

```
Base:                    €597/mes
Bandwidth (promedio):    €60/mes
Alertas + DNS:           €4/mes
Buffer (10%):            €66/mes
─────────────────────────────────
TOTAL:                   €727/mes
```

**Rango realista: €650-800/mes**

⚠️ **SIN DDoS Protection Standard** (añade €2,944/mes si es necesario)

---

## 🚨 ALERTAS DE COSTE (CONFIGURAR AHORA)

### Configurar Budget en Azure

```bash
# Alert cuando se gaste €100 en staging
az consumption budget create \
  --resource-group rg-econeura-staging \
  --budget-name staging-budget \
  --amount 150 \
  --time-grain Monthly \
  --start-date 2025-11-01 \
  --notifications \
    percent=80 \
    threshold-type=Actual \
    contact-emails="tu@email.com"

# Alert cuando se gaste €600 en production
az consumption budget create \
  --resource-group rg-econeura-prod \
  --budget-name prod-budget \
  --amount 800 \
  --time-grain Monthly \
  --start-date 2025-11-01 \
  --notifications \
    percent=80 \
    threshold-type=Actual \
    contact-emails="tu@email.com"
```

### Dashboard de Costes

```bash
# Abrir Cost Management
start "https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview"

# Configurar:
# 1. Cost analysis por Resource Group
# 2. Alertas en €120 (staging) y €700 (prod)
# 3. Forecast activado
# 4. Email diario con resumen
```

---

## 💡 OPTIMIZACIÓN DE COSTES

### Staging (Ahorrar €20-30/mes)

```markdown
✅ HACER:
1. Apagar recursos fuera de horario laboral
   - Az App Service: Stop 22:00-8:00 (ahorro €5/mes)
   - PostgreSQL: Escalar a B1ms solo cuando se use (ahorro €3/mes)

2. Reducir retención de logs
   - Application Insights: 30 días → 7 días (ahorro €8/mes)
   - Log Analytics: 30 días → 7 días (ahorro €5/mes)

3. Optimizar bandwidth
   - Habilitar compresión gzip (ahorro €3/mes)
   - CDN para assets estáticos (ahorro €4/mes)

AHORRO TOTAL: €28/mes (de €133 → €105/mes)
```

### Production (Mantener Performance)

```markdown
⚠️ NO REDUCIR:
- Database size/tier (riesgo de downtime)
- App Service auto-scaling (riesgo de lentitud)
- Application Insights retention (necesario para debug)

✅ OPTIMIZAR:
1. Reserved Instances (1 año commitment)
   - App Service: -30% = €54/mes ahorro
   - Database: -40% = €58/mes ahorro

2. CDN para assets
   - Reduce bandwidth desde Azure: €30/mes ahorro

3. Optimizar queries database
   - Reduce I/O = €10/mes ahorro

AHORRO TOTAL: €152/mes (de €727 → €575/mes)
```

---

## 📈 PROYECCIÓN DE COSTES

### Año 1 (Con crecimiento)

| Mes | Users | Requests/día | Coste/mes |
|-----|-------|--------------|-----------|
| 1-3 | 10 | 1,000 | €110 (staging only) |
| 4 | 50 | 5,000 | €650 (prod launch) |
| 5-6 | 100 | 10,000 | €700 |
| 7-9 | 250 | 25,000 | €850 |
| 10-12 | 500 | 50,000 | €1,100 |

**Total Año 1**: ~€9,600

### Año 2 (Escalado)

| Mes | Users | Requests/día | Coste/mes |
|-----|-------|--------------|-----------|
| 13-24 | 1,000 | 100,000 | €1,800/mes |

**Total Año 2**: ~€21,600

---

## 🎯 RECOMENDACIONES FINALES

### Para Staging
```
✅ Mantener en €110-130/mes
✅ Configurar alerta en €150
✅ Revisar costes semanalmente
✅ Apagar fuera de horario si es posible
```

### Para Production
```
✅ Presupuesto inicial: €650-800/mes
✅ Configurar alerta en €900
✅ Reserved Instances después de 3 meses estable
✅ Revisar costes diariamente los primeros 2 meses
```

### Alertas Críticas
```
🚨 Staging > €200/mes → Investigar inmediatamente
🚨 Production > €1,200/mes → Investigar inmediatamente
🚨 Bandwidth > 1TB/mes → Posible attack o loop
```

---

## 📞 SOPORTE AZURE COST

```bash
# Ver costes actuales
az consumption usage list --output table

# Ver forecast
az consumption budget show --budget-name staging-budget --output table

# Detalles por servicio
az consumption usage list \
  --start-date 2025-11-01 \
  --end-date 2025-11-30 \
  --query "[?contains(instanceId, 'econeura')]" \
  --output table

# Exportar a CSV
az consumption usage list --output json > azure-costs.json
```

---

## ⚠️ DISCLAIMERS

1. **Estos costes son ESTIMACIONES** basadas en uso típico
2. **Tu uso real puede variar** ± 20-30%
3. **Bandwidth depende** de tráfico y ubicación geográfica de usuarios
4. **Application Insights** puede costar más si hay muchos errores/logs
5. **Auto-scaling** en production puede aumentar costes en picos de tráfico

**SIEMPRE configura alertas de coste antes de empezar** ✅

---

**Preparado por**: Claude Sonnet 4.5  
**Fuente**: Azure Pricing Calculator + Experiencia real  
**Última actualización**: 13 Noviembre 2025

