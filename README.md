# argos-exts

Coleção de extensões para [Argos](https://github.com/p-e-w/argos) (GNOME Shell) e [BitBar](https://github.com/matryer/bitbar) (macOS) para monitoramento de sistema, rede e conectividade.

## 📋 Índice

- [Extensões Disponíveis](#-extensões-disponíveis)
  - [Connection Checker](#-connection-checker)
  - [External IP](#-external-ip)
  - [Speedtest](#-speedtest)
  - [Battery Monitor](#-battery-monitor)
  - [Shell Log](#-shell-log)
- [Instalação](#-instalação)
- [Configuração](#️-configuração)
- [Licença](#-licença)

## 🔌 Extensões Disponíveis

### 🌐 Connection Checker
**Arquivo:** `conn.1m.sh` (atualiza a cada 1 minuto)

Monitora e exibe o status da sua conexão, detectando automaticamente qual DNS ou VPN você está usando:

**Serviços detectados:**
- **[AdGuard DNS](https://adguard.com/en/adguard-dns/overview.html#setup-guide)** - Adblock, Family ou Unfiltered
  - DNS padrão
  - DNS-over-TLS (DoT)
  - DNS-over-HTTPS (DoH)
  - DNSCrypt
- **[Cloudflare 1.1.1.1](https://1.1.1.1)** - DNS ou WARP VPN
  - Detecta DNS padrão, DoT, DoH
  - Identifica conexão via WARP VPN com localização do servidor
- **[NextDNS](https://nextdns.io)** - DNS customizável

**Recursos extras:**
- Atualização automática de DNS dinâmico (DuckDNS e NextDNS)
- Links diretos para Google Maps mostrando localização do servidor
- Interface visual clara mostrando protocolo e tipo de conexão

**Dependências:**
- `curl`
- `jq`
- `xclip`
- `uuidgen`

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/insign/argos-exts/.github/adguard.png">
  <img src="https://cdn.jsdelivr.net/gh/insign/argos-exts/.github/cf.png">
</p>

---

### 🌍 External IP
**Arquivo:** `external-ip.1h.sh` (atualiza a cada 1 hora)

Exibe seus endereços IP externos IPv4 e IPv6.

**Funcionalidades:**
- Mostra IPv4 e IPv6 simultaneamente
- Clique para copiar qualquer IP para a área de transferência
- Notificação visual quando copiado
- Botão de atualização manual
- Timeout de 4 segundos para respostas rápidas

**Dependências:**
- `curl`
- `xclip` - Para funcionalidade de copiar
- `notify-send` - Para notificações (opcional)

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/insign/argos-exts/.github/ip.png">
</p>

---

### ⚡ Speedtest
**Arquivo:** `speedtest.1h.sh` (atualiza a cada 1 hora)

Testa e exibe a velocidade da sua conexão com suporte para múltiplos backends.

**Backends suportados (em ordem de prioridade):**
1. **[speedtest++](https://github.com/taganaka/SpeedTest)** - Mais rápido e leve (recomendado)
2. **[sivel/speedtest-cli](https://github.com/sivel/speedtest-cli)** - Python-based, amplamente usado
3. **[Ookla Speedtest CLI](https://www.speedtest.net/apps/cli)** - Oficial da Speedtest.net

**Funcionalidades:**
- Exibe download, upload e ping
- Mostra ISP e IP público
- Informações do servidor de teste com link para mapa
- Compartilhamento de resultados (quando disponível)
- Clique para copiar IP
- Seleção manual de servidor (opcional)

**Configuração de servidor:**
```bash
# No início do arquivo, descomente e configure se desejar:
SERVER_ID=10843  # ID do servidor específico
```

**Dependências:**
- Um dos backends: `speedtest++`, `speedtest-cli` ou `speedtest`
- `jq` - Para parsing JSON
- `xclip` - Para copiar para área de transferência
- `awk` - Para cálculos (geralmente já instalado)
- `notify-send` - Para notificações (opcional)

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/insign/argos-exts/.github/speedtest.png">
</p>

---

### 🔋 Battery Monitor
**Arquivo:** `bateria.2s.sh` (atualiza a cada 2 segundos)

Monitor avançado de bateria com informações detalhadas de energia.

**Funcionalidades:**
- **Painel:** Potência atual (W) e porcentagem
- **Menu detalhado:**
  - Estado (carregando/descarregando)
  - Status da entrada elétrica (Mains)
  - Potência via UPower e sysfs
  - Tensão (V) via ambas as fontes
  - Corrente (mA) quando disponível
  - Tempo estimado até 100% ou 0%
  - Atalho para pasta sysfs da bateria
  - Atalho para configurações de energia do sistema

**Indicadores visuais:**
- 🔋 Descargando (branco, vermelho se < 20%)
- ⚡ Carregando (azul)

**Fontes de dados:**
- UPower - Informações gerais do sistema
- sysfs - Leituras diretas do kernel para maior precisão

**Dependências:**
- `upower` - Geralmente pré-instalado em distribuições modernas
- `awk` - Para cálculos

---

### 📜 Shell Log
**Arquivo:** `shell_log.1s.sh` (atualiza a cada 1 segundo)

Exibe a última entrada do log do GNOME Shell em tempo real.

**Funcionalidades:**
- Mostra última mensagem do journalctl do gnome-shell
- Texto truncado em 40 caracteres para economizar espaço
- Acesso rápido ao log completo via terminal
- Útil para debug de extensões e temas

**Dependências:**
- `journalctl` - Geralmente pré-instalado no systemd
- GNOME Shell

---

## 📦 Instalação

### 1. Instalar Argos (GNOME) ou BitBar (macOS)

**GNOME Shell (Linux):**
```bash
# Via GNOME Extensions
https://extensions.gnome.org/extension/1176/argos/
```

**macOS:**
```bash
brew install bitbar
```

### 2. Clonar este repositório

```bash
git clone https://github.com/insign/argos-exts.git
cd argos-exts
```

### 3. Instalar dependências

**Arch Linux / Manjaro:**
```bash
sudo pacman -S curl jq xclip upower
# Escolha um backend de speedtest:
yay -S speedtest++ # Recomendado
# OU
sudo pacman -S speedtest-cli
# OU
yay -S speedtest-cli-bin # Ookla oficial
```

**Ubuntu / Debian:**
```bash
sudo apt install curl jq xclip upower
# Escolha um backend de speedtest:
sudo apt install speedtest-cli
# OU baixe speedtest++ do GitHub
# OU baixe Ookla CLI do site oficial
```

**Fedora:**
```bash
sudo dnf install curl jq xclip upower
sudo dnf install speedtest-cli
```

### 4. Copiar scripts para o diretório do Argos/BitBar

**Argos (GNOME):**
```bash
mkdir -p ~/.config/argos
cp *.sh ~/.config/argos/
chmod +x ~/.config/argos/*.sh
```

**BitBar (macOS):**
```bash
# Copie para o diretório configurado no BitBar
cp *.sh ~/BitBar/
chmod +x ~/BitBar/*.sh
```

## ⚙️ Configuração

### Intervalo de atualização

O intervalo é definido no nome do arquivo:
- `.1s.sh` = 1 segundo
- `.2s.sh` = 2 segundos
- `.1m.sh` = 1 minuto
- `.1h.sh` = 1 hora

Para alterar, renomeie o arquivo:
```bash
mv speedtest.1h.sh speedtest.30m.sh  # Muda de 1 hora para 30 minutos
```

### Speedtest - Servidor específico

Edite `speedtest.1h.sh` e descomente/configure:
```bash
SERVER_ID=10843  # Substitua pelo ID do seu servidor preferido
```

Para encontrar IDs de servidores:
```bash
speedtest-cli --list | grep "Sua Cidade"
# OU
speedtest --servers
```

### Connection Checker - DynDNS personalizado

Edite `conn.1m.sh` e modifique as linhas 68-69:
```bash
curl -s https://www.duckdns.org/update?domains=SEUDOMINIO&token=SEUTOKEN >/dev/null
curl -s https://link-ip.nextdns.io/SEUPROFILE/SEUTOKEN >/dev/null
```

## 📄 Licença

[Do What the Fuck You Want to Public License](LICENSE.md)

---

<p align="center">
  Desenvolvido com ☕ por <a href="https://github.com/insign">Hélio</a>
</p>
