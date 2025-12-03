# 🔐 Setup de Noir y Garaga para ZumpFun

## ⚠️ Información Importante de la Hackathon

Según la información compartida, hay requisitos específicos y problemas conocidos:

### Versiones Requeridas
- **Noir**: 1.0.0-beta.1
- **Barretenberg (bb)**: 0.67.0
- **Garaga**: 0.15.5 para Cairo verifiers
- **Scarb**: 2.9.2 (tenemos 2.12.2, puede necesitar ajuste)

### ⚠️ Problemas Conocidos

1. **Barretenberg NO funciona bien en macOS**
   - Crashes aleatorios
   - Errores de símbolos faltantes
   - Errores de dylib
   - **Solución**: Usar GitHub Codespaces o Linux

2. **sncast también crashea en Mac**
   - Bug de SystemConfiguration
   - **Solución**: Ejecutar desde Codespaces o shell Linux

3. **Garaga calldata es GRANDE**
   - Circuitos pequeños generan ~79KB de calldata
   - Considerar gas costs

---

## 🚀 Opciones de Setup

### Opción 1: WSL (Windows Subsystem for Linux) - ✅ RECOMENDADO

**Ventajas**:
- ✅ Mejor compatibilidad que Windows nativo
- ✅ Funciona como Linux
- ✅ Menos problemas de paths
- ✅ Rust ya está instalado en WSL

**Setup**:
```bash
# Desde WSL, navegar al proyecto
cd /mnt/c/Users/monst/zeroshade

# Ejecutar script de setup
bash scripts/setup_wsl.sh
```

**Nota**: Si necesitas resetear la contraseña de WSL:
```powershell
# En PowerShell como Administrador
wsl -u root
passwd monst
exit
```

### Opción 2: GitHub Codespaces (Más Fácil)

1. **Crear Codespace**
   - Ve a tu repositorio en GitHub
   - Click en "Code" > "Codespaces" > "Create codespace"
   - Espera a que se inicialice

2. **Instalar Barretenberg**
   ```bash
   curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/master/barretenberg/cpp/installation/install | bash
   ```

3. **Instalar Noir**
   ```bash
   # Instalar Noir 1.0.0-beta.1
   curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
   source ~/.bashrc
   noirup --version 1.0.0-beta.1
   ```

4. **Instalar Garaga**
   ```bash
   # Instalar Garaga 0.15.5
   cargo install --git https://github.com/keep-starknet-strange/garaga.git --tag v0.15.5 garaga
   ```

5. **Verificar Scarb**
   ```bash
   scarb --version  # Debería ser 2.9.2 según recomendación
   ```

---

## 🛠️ Flujo de Trabajo con Noir + Garaga

### 1. Crear Circuito Noir

```bash
# Crear nuevo proyecto Noir
nargo new private_trading
cd private_trading
```

### 2. Compilar Circuito

```bash
nargo compile
```

### 3. Generar Witness

```bash
nargo execute witness
```

### 4. Generar Prueba con Barretenberg

```bash
bb prove_ultra_keccak_honk \
  -b ./target/your_circuit.json \
  -w ./target/witness.gz \
  -o ./target/proof
```

### 5. Generar Verification Key

```bash
bb write_vk_ultra_keccak_honk \
  -b ./target/your_circuit.json \
  -o ./target/vk
```

### 6. Generar Verifier Contract con Garaga

```bash
# Crear directorio para el verifier
mkdir verifier_project
cd verifier_project

# Copiar archivos necesarios:
# - verification_key.json (del paso 5)
# - proof.json (del paso 4)
# - public_inputs.json (si aplica)

# Generar código del verificador
garaga gen
```

### 7. Configurar .secrets

Crear archivo `.secrets` basado en `.secrets.template`:
```
STARKNET_RPC_URL=...
STARKNET_ACCOUNT_ADDRESS=...
STARKNET_PRIVATE_KEY=...
```

### 8. Declarar Contrato (costoso)

```bash
garaga declare
# Guarda el class_hash que retorna
```

### 9. Deploy Verifier

```bash
garaga deploy --class-hash <class_hash_del_paso_anterior>
# Guarda la dirección del contrato
```

### 10. Verificar Proof On-Chain

```bash
garaga verify-onchain \
  --contract-address <direccion_verifier> \
  --vk <verification_key.json> \
  --proof <proof.json> \
  --public-inputs <public_inputs.json>
```

### Alternativa: Generar Calldata para Verificación Manual

```bash
garaga calldata \
  --system ultra_keccak_honk \
  --vk ./target/vk \
  --proof ./target/proof \
  --format starknet > calldata.txt
```

Luego llamar manualmente al contrato verifier con el calldata.

---

## 📁 Estructura de Proyecto Actualizada

```
zeroshade/
├── src/
│   ├── contracts/
│   │   ├── token.cairo
│   │   ├── launchpad.cairo
│   │   └── token_factory.cairo
│   └── noir/                    # Nuevo: Circuitos Noir
│       └── private_trading/
│           ├── src/
│           │   └── main.nr      # Circuito de trading privado
│           └── Nargo.toml
├── garaga/                      # Nuevo: Verifiers Garaga
│   └── verifier.cairo
└── scripts/
    ├── setup_noir.sh
    └── generate_proof.sh
```

---

## 🔧 Scripts de Setup

### setup_noir.sh

```bash
#!/bin/bash
# Setup completo de Noir + Garaga + Barretenberg

echo "🔐 Configurando Noir y Garaga para ZumpFun..."

# Instalar Barretenberg
echo "📦 Instalando Barretenberg..."
curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/master/barretenberg/cpp/installation/install | bash

# Instalar Noir
echo "📦 Instalando Noir..."
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
source ~/.bashrc
noirup --version 1.0.0-beta.1

# Instalar Garaga
echo "📦 Instalando Garaga..."
cargo install --git https://github.com/keep-starknet-strange/garaga.git --tag v0.15.5 garaga

echo "✅ Setup completado!"
echo ""
echo "Verificar instalaciones:"
echo "  bb --version"
echo "  nargo --version"
echo "  garaga --version"
```

---

## 🧪 Testing del Flujo Completo

### Test en Sepolia

Verifier contract desplegado en:
```
0x022b20fef3764d09293c5b377bc399ae7490e60665797ec6654d478d74212669
```

Puedes probar llamando al verifier con calldata generado.

---

## 📝 Notas Importantes

1. **Usa Codespaces si estás en Mac** - Ahorrarás horas de debugging
2. **Versiones exactas** - Usa las versiones especificadas para evitar problemas
3. **Calldata size** - Considera el tamaño del calldata en tus cálculos de gas
4. **Testing** - Prueba en Sepolia antes de mainnet

---

## 🔗 Recursos

- [Noir Documentation](https://noir-lang.org/)
- [Garaga GitHub](https://github.com/keep-starknet-strange/garaga)
- [Barretenberg Installation](https://github.com/AztecProtocol/aztec-packages/tree/master/barretenberg/cpp/installation)
- [GitHub Codespaces](https://github.com/features/codespaces)

---

## ✅ Checklist de Setup

- [ ] Crear/Configurar Codespace (si estás en Mac)
- [ ] Instalar Barretenberg 0.67.0
- [ ] Instalar Noir 1.0.0-beta.1
- [ ] Instalar Garaga 0.15.5
- [ ] Verificar Scarb 2.9.2 (o compatible)
- [ ] Crear primer circuito Noir
- [ ] Probar flujo completo de proof generation
- [ ] Deploy verifier contract
- [ ] Probar verificación en testnet

---

**¡Setup listo para privacidad con Noir y Garaga!** 🔐

