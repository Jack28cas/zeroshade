# Testing del Circuito Noir

## ⚠️ IMPORTANTE: Ejecutar en WSL

Todos los comandos de Noir deben ejecutarse en **WSL (Ubuntu)**, no en Git Bash de Windows.

## Pasos para Probar

### 1. Abrir WSL

```bash
# Desde Windows, abre Ubuntu (WSL)
# O desde terminal: wsl
```

### 2. Navegar al directorio del proyecto

```bash
# El proyecto está en /mnt/c/Users/monst/zeroshade
cd /mnt/c/Users/monst/zeroshade/src/noir/private_trading
```

### 3. Verificar que Noir está instalado

```bash
nargo --version
# Debería mostrar: nargo 1.0.0-beta.1
```

### 4. Compilar el circuito

```bash
nargo compile
```

### 5. Generar witness

```bash
nargo execute witness
```

### 6. Generar proof completo

```bash
# Desde la raíz del proyecto
cd /mnt/c/Users/monst/zeroshade
./scripts/generate_proof.sh private_trading
```

## Solución de Problemas

### Si `nargo` no se encuentra en WSL:

```bash
# Verificar que está en PATH
echo $PATH | grep -i noir

# Si no está, agregar a ~/.bashrc
export PATH="$HOME/.noirup/bin:$PATH"
source ~/.bashrc
```

### Si hay errores de compilación:

- Verificar que `Nargo.toml` tiene la versión correcta
- Verificar que `src/main.nr` tiene sintaxis válida
- Revisar mensajes de error específicos

