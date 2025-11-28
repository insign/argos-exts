# Como ocultar o indicador nativo de bateria do GNOME

Agora que você tem um indicador de bateria customizado via Argos, pode querer ocultar o ícone nativo do GNOME para evitar duplicação.

## Opção 1: Ocultar apenas a porcentagem

```bash
gsettings set org.gnome.desktop.interface show-battery-percentage false
```

Isso mantém o ícone mas remove a porcentagem ao lado.

## Opção 2: Ocultar completamente o ícone (via extensão)

### Usando Just Perfection (Recomendado)

1. **Instalar a extensão:**
   ```bash
   # Via GNOME Extensions
   # https://extensions.gnome.org/extension/3843/just-perfection/

   # Ou via pacote (Arch Linux)
   yay -S gnome-shell-extension-just-perfection-git
   ```

2. **Habilitar a extensão:**
   ```bash
   gnome-extensions enable just-perfection-desktop@just-perfection
   ```

3. **Ocultar o ícone de bateria:**
   ```bash
   gsettings set org.gnome.shell.extensions.just-perfection power-icon false
   ```

### Usando Hide Top Bar (Alternativa)

1. **Instalar:**
   ```bash
   # https://extensions.gnome.org/extension/545/hide-top-bar/
   ```

2. **Configurar** via interface gráfica para ocultar apenas o ícone de bateria.

## Opção 3: Customizar via dconf-editor

1. **Instalar dconf-editor:**
   ```bash
   sudo pacman -S dconf-editor
   ```

2. **Abrir e navegar:**
   ```bash
   dconf-editor
   ```

3. **Ir para:**
   ```
   /org/gnome/shell/extensions/
   ```

4. Procure por extensões que controlam o painel superior.

## Para reverter (mostrar ícone nativo novamente)

```bash
# Mostrar porcentagem
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Mostrar ícone (Just Perfection)
gsettings set org.gnome.shell.extensions.just-perfection power-icon true
```

## Verificar configuração atual

```bash
# Ver se porcentagem está visível
gsettings get org.gnome.desktop.interface show-battery-percentage

# Ver se ícone está visível (Just Perfection)
gsettings get org.gnome.shell.extensions.just-perfection power-icon
```

## Nota importante

O GNOME não permite ocultar o ícone de bateria nativamente sem extensões por questões de segurança e UX - é importante que o usuário sempre saiba o estado da bateria.

Por isso, certifique-se de que seu script Argos está funcionando corretamente antes de ocultar o ícone nativo!
