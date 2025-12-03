# 🗺️ Roadmap Actualizado - ZumpFun

## 📋 Consideraciones de la Hackathon

Basado en la información compartida, hemos actualizado el roadmap para incluir los requisitos específicos de Noir y Garaga.

---

## ✅ Fase 1: Contratos Base (COMPLETADO)

- ✅ Token Contract (Cairo)
- ✅ Launchpad Contract (Cairo)
- ✅ Token Factory (Cairo)
- ✅ Tests básicos creados

---

## ✅ Fase 2: Testing (COMPLETADO)

- ✅ Configuración de Starknet Foundry
- ✅ Tests para Token Contract
- ✅ Tests para Launchpad Contract
- ⏳ Ejecutar tests (requiere snforge instalado)

---

## 🔄 Fase 3: Setup Noir + Garaga (NUEVO - PRIORITARIO)

### Requisitos
- **Noir**: 1.0.0-beta.1
- **Barretenberg**: 0.67.0
- **Garaga**: 0.15.5
- **Scarb**: 2.9.2 (verificar compatibilidad)

### Tareas
- [ ] Configurar GitHub Codespaces (si estás en Mac)
- [ ] Instalar Barretenberg
- [ ] Instalar Noir
- [ ] Instalar Garaga
- [ ] Crear primer circuito Noir (private trading)
- [ ] Probar flujo completo de proof generation
- [ ] Integrar verifier de Garaga

**Ver**: `NOIR_GARAGA_SETUP.md` para guía completa

---

## ⏳ Fase 4: Backend API

- [ ] API REST/GraphQL
- [ ] Event indexing
- [ ] User management
- [ ] Price aggregation
- [ ] Integration con contratos

---

## ⏳ Fase 5: Frontend

- [ ] Launch interface
- [ ] Trading interface
- [ ] Portfolio view
- [ ] Token explorer

---

## ⏳ Fase 6: Privacidad (Noir)

- [ ] Private trading circuit
- [ ] ZK proofs para ocultación
- [ ] Identity hiding
- [ ] Integration con Launchpad

---

## ⏳ Fase 7: Garaga Integration

- [ ] Market-making automático
- [ ] Price discovery avanzado
- [ ] Advanced trading features

---

## 🎯 Prioridades Actualizadas

### Inmediato (Para cumplir requisitos de hackathon)
1. **Setup Noir + Garaga** ⚠️ CRÍTICO
2. Crear circuito básico de privacidad
3. Integrar verifier de Garaga

### Corto Plazo
4. Backend API básico
5. Frontend MVP
6. Testing completo

### Medio Plazo
7. Features avanzadas
8. Optimizaciones
9. Documentación final

---

## ⚠️ Advertencias Importantes

1. **macOS Issues**
   - Barretenberg no funciona bien en Mac
   - Usar GitHub Codespaces o Linux
   - sncast también tiene problemas en Mac

2. **Versiones Exactas**
   - Usar las versiones especificadas
   - Evitar actualizar sin verificar compatibilidad

3. **Calldata Size**
   - Garaga genera calldata grande (~79KB para circuitos pequeños)
   - Considerar gas costs

---

## 📅 Timeline Sugerido

### Semana 1-2: Setup y Privacidad
- Setup Noir + Garaga
- Crear circuitos básicos
- Integrar verifiers

### Semana 3: Backend
- API básica
- Event indexing
- Integration testing

### Semana 4: Frontend
- UI básica
- Integration con backend
- Testing end-to-end

---

## 🔗 Recursos

- `NOIR_GARAGA_SETUP.md` - Guía completa de setup
- `ARCHITECTURE.md` - Arquitectura del sistema
- `CONTRACTS_GUIDE.md` - Guía de contratos

---

**Roadmap actualizado con requisitos de la hackathon** 🚀

