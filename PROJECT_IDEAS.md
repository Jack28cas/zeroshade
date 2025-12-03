# 💡 Ideas de Proyectos para la Hackathon

Este documento detalla las diferentes opciones de proyectos disponibles en la Zypherpunk Hackathon.

## 🏆 Opción 1: Wildcard - Innovación Única ($20,000)

**El premio más grande** para algo completamente inesperado y de alto impacto.

### Ideas posibles:
- **Perps privados**: Derivados perpétuos con privacidad
- **Préstamos y créditos privados**: Sistema de préstamos descentralizado con privacidad
- **Mercado de predicción privado**: Usando contratos Noir y Garaga sobre Ztarknet

### Stack técnico sugerido:
- Contratos Cairo para lógica principal
- Contratos Noir para privacidad
- Garaga para funcionalidades avanzadas
- Integración con Ztarknet

---

## 🪙 Opción 2: ZumpFun - Pump.fun Privado ($5,000)

### Concepto:
Un launchpad de meme-coins donde:
- El trading permanece oculto
- El market-making es privado
- La identidad del creador está oculta

### Requisitos técnicos:
- ✅ Debe usar **contratos Noir** (para privacidad)
- ✅ Debe usar **Garaga** (para funcionalidades avanzadas)
- ✅ Debe funcionar sobre **Ztarknet**

### Funcionalidades clave:
1. **Creación de tokens**: Los usuarios pueden crear nuevos meme-coins
2. **Trading privado**: Las transacciones no revelan información
3. **Market-making automático**: Similar a Pump.fun pero privado
4. **Ocultación de identidad**: El creador puede permanecer anónimo

### Stack técnico:
```
- Contratos Cairo (lógica base)
- Contratos Noir (privacidad)
- Garaga (funcionalidades avanzadas)
- Ztarknet (blockchain)
```

---

## 💰 Opción 3: Micropagos en Zashi Wallet ($1,000)

### Concepto:
Implementar un sistema de micropagos en la billetera Zashi donde las transacciones liquidan en Starknet.

### Requisitos:
- Integración con Zashi Wallet
- Sistema de micropagos eficiente
- Liquidación en Starknet

### Funcionalidades:
- Envío de micropagos desde Zashi
- Agregación de transacciones
- Liquidación batch en Starknet
- UI/UX intuitiva

---

## 🛠️ Opción 4: Construyendo sobre Ztarknet ($3,000)

### Concepto:
Construir herramientas de desarrollo o aplicaciones sobre la implementación actual de Ztarknet.

### Posibles proyectos:
- Explorador de bloques para Ztarknet
- Herramientas de desarrollo (SDKs, librerías)
- Aplicaciones de ejemplo
- Documentación y tutoriales

### Requisitos:
- Debe funcionar en testnet de Ztarknet
- Debe ser útil para la comunidad
- Debe estar bien documentado

---

## 🔗 Opción 5: Mensajería Cross-Chain ($3,000)

### Concepto:
Crear un orquestador y capa de relay que:
- Escuche transacciones o cambios de estado en una cadena (Starknet/Zcash)
- Los replique o active acciones en la otra cadena

### Arquitectura sugerida:
```
Starknet <---> Orquestador <---> Zcash
                (Relay Layer)
```

### Funcionalidades:
- Monitoreo de eventos en ambas cadenas
- Relay de mensajes
- Sincronización de estado
- Validación de transacciones

### Stack técnico:
- Contratos Cairo en Starknet
- Integración con Zcash
- Servicio de orquestación (backend)
- Sistema de relay

---

## 👛 Opción 6: Billetera Zec <> Starknet ($3,000)

### Concepto:
Crear una interfaz única agregando capacidades multichain a Zashi Wallet para:
- Almacenar y blindar ZEC
- Gestionar activos de Starknet
- Interoperabilidad entre ambas cadenas

### Funcionalidades:
- Gestión de ZEC (Zcash)
- Gestión de activos Starknet
- Blindaje/desblindaje de ZEC
- Interfaz unificada

---

## 🔄 Opción 7: Atomic Swap (Zec <-> Starknet) ($3,000)

### Concepto:
Permitir intercambio directo sin intermediarios entre Zcash y Starknet.

### Funcionalidades:
- Swap atómico ZEC ↔ STRK (o tokens Starknet)
- Sin intermediarios (trustless)
- Seguridad garantizada por smart contracts
- UI para facilitar el swap

### Requisitos técnicos:
- Contratos HTLC (Hash Time Lock Contract) o similar
- Integración con ambas blockchains
- Frontend intuitivo

---

## 📊 Comparación Rápida

| Proyecto | Premio | Complejidad | Stack Principal |
|----------|--------|-------------|-----------------|
| Wildcard | $20k | Alta | Cairo + Noir + Garaga |
| ZumpFun | $5k | Media-Alta | Noir + Garaga + Ztarknet |
| Micropagos | $1k | Media | Zashi + Starknet |
| Ztarknet Tools | $3k | Media | Ztarknet + Cairo |
| Cross-Chain | $3k | Alta | Starknet + Zcash + Backend |
| Billetera | $3k | Alta | Zashi + Starknet + Frontend |
| Atomic Swap | $3k | Alta | HTLC + Starknet + Zcash |

---

## 🎯 Recomendación

Para maximizar las probabilidades de ganar:

1. **ZumpFun ($5k)**: Buena relación premio/complejidad, requisitos claros
2. **Wildcard ($20k)**: Mayor premio pero más competencia
3. **Micropagos ($1k)**: Más simple, buen punto de partida

### Para empezar rápido:
- **ZumpFun**: Si quieres algo desafiante pero con requisitos claros
- **Micropagos**: Si quieres algo más simple para empezar
- **Wildcard**: Si tienes una idea innovadora única

---

## 🚀 Próximos Pasos

1. **Elegir el proyecto** que más te interese
2. **Investigar los requisitos técnicos** específicos
3. **Diseñar la arquitectura** del sistema
4. **Empezar con los contratos** (como recomienda tu amigo)
5. **Testing exhaustivo**
6. **Backend y Frontend** una vez que los contratos funcionen

---

**¿Cuál proyecto te interesa más?** 🎯

