#!/usr/bin/env bash
# bateria.2s.sh — Argos: atualiza a cada 2 segundos
#
# Para ocultar o indicador nativo de bateria do GNOME e usar apenas este:
# gsettings set org.gnome.desktop.interface show-battery-percentage false
#
# Para ocultar completamente o ícone nativo (requer extensão):
# 1. Instale a extensão "Just Perfection"
# 2. Ou use: gsettings set org.gnome.shell.extensions.power-icon hide true
#
# Para reverter (mostrar ícone nativo novamente):
# gsettings set org.gnome.desktop.interface show-battery-percentage true

# Não falhar em campos ausentes
set -u

get_bat_upower() {
  upower -e 2>/dev/null | grep -E '/battery_' | head -n1
}

get_bat_sysfs() {
  # Primeiro tenta pelo native-path do UPower
  local up dev
  up=$(get_bat_upower)
  if [ -n "$up" ]; then
    dev=$(upower -i "$up" 2>/dev/null | awk -F': *' '/native-path:/{print $2; exit}')
    [ -n "$dev" ] && [ -d "/sys/class/power_supply/$dev" ] && { echo "/sys/class/power_supply/$dev"; return; }
  fi
  # Fallback: primeiro BAT* existente
  for d in /sys/class/power_supply/BAT*; do [ -d "$d" ] && { echo "$d"; return; }; done
  echo ""
}

get_mains_sysfs() {
  for d in /sys/class/power_supply/*; do
    [ -f "$d/type" ] && grep -q "^Mains$" "$d/type" && { echo "$d"; return; }
  done
  echo ""
}

UP_BAT="$(get_bat_upower)"
SYS_BAT="$(get_bat_sysfs)"

# Campos via UPower (força locale em C p/ ponto decimal onde necessário)
state="$(upower -i "$UP_BAT" 2>/dev/null | awk -F': *' '/state:/{print $2; exit}')"
percent="$(upower -i "$UP_BAT" 2>/dev/null | awk -F': *' '/percentage:/{gsub("%","",$2); print $2; exit}')"
erate="$(LC_ALL=C upower -i "$UP_BAT" 2>/dev/null | awk -F': *' '/energy-rate:/{gsub(" W","",$2); print $2; exit}')"
voltage_up="$(LC_ALL=C upower -i "$UP_BAT" 2>/dev/null | awk -F': *' '/voltage:/{gsub(" V","",$2); print $2; exit}')"
ttfull="$(upower -i "$UP_BAT" 2>/dev/null | awk -F': *' '/time to full:/{print $2; exit}')"
ttempty="$(upower -i "$UP_BAT" 2>/dev/null | awk -F': *' '/time to empty:/{print $2; exit}')"

# Cálculo via sysfs
p_sysfs=""; i_ma=""; v_v=""
if [ -n "$SYS_BAT" ] && [ -f "$SYS_BAT/voltage_now" ] && [ -f "$SYS_BAT/current_now" ]; then
  v=$(cat "$SYS_BAT/voltage_now" 2>/dev/null)
  i=$(cat "$SYS_BAT/current_now" 2>/dev/null)
  # Potência absoluta em W (µV * µA / 1e12); corrente pode ter sinal invertido em alguns drivers
  p_sysfs=$(awk -v v="$v" -v i="$i" 'BEGIN{p=v*i/1e12; if(p<0)p=-p; printf "%.2f", p}')
  v_v=$(awk -v v="$v" 'BEGIN{printf "%.2f", v/1e6}')
  i_ma=$(awk -v i="$i" 'BEGIN{if(i<0)i=-i; printf "%.0f", i/1000}')
fi

# Entrada (Mains) online
mains="$(get_mains_sysfs)"
online=""
[ -n "$mains" ] && [ -f "$mains/online" ] && online="$(cat "$mains/online" 2>/dev/null)"

# Determinar ícone baseado no nível e estado
get_battery_icon() {
  local pct="$1"
  local st="$2"

  # Arredondar para múltiplos de 10
  local level=$((pct / 10 * 10))
  [ "$level" -gt 100 ] && level=100
  [ "$level" -lt 0 ] && level=0

  # Determinar sufixo baseado no estado
  local suffix=""
  if [ "$st" = "charging" ]; then
    suffix="-charging"
  elif [ "$st" = "fully-charged" ] || [ "$st" = "charged" ]; then
    suffix="-charged"
  fi

  # Casos especiais
  if [ "$pct" -eq 100 ] && [ "$st" = "fully-charged" ]; then
    echo "battery-level-100-charged-symbolic"
  elif [ "$pct" -le 5 ]; then
    echo "battery-level-0${suffix}-symbolic"
  else
    echo "battery-level-${level}${suffix}-symbolic"
  fi
}

# Obter ícone apropriado
icon_name=$(get_battery_icon "${percent:-50}" "$state")

# Determinar cor
if [ "$state" = "discharging" ]; then
  if [ -n "$percent" ] && [ "$percent" -lt 20 ]; then
    color="color=#ff5555"
  else
    color="color=#f8f8f2"
  fi
else
  color="color=#8be9fd"
fi

# Linha do painel
# Não mostrar W quando totalmente carregado (potência ~0)
if [ "$state" = "fully-charged" ] || ([ "$percent" -eq 100 ] && [ "$state" = "charging" ]); then
  echo "${percent}% | iconName=$icon_name $color"
elif [ -n "$p_sysfs" ]; then
  echo "${p_sysfs}W ${percent}% | iconName=$icon_name $color"
elif [ -n "$erate" ]; then
  echo "${erate}W ${percent}% | iconName=$icon_name $color"
else
  echo "${percent}% | iconName=$icon_name $color"
fi

# Menu
echo "---"
echo "Estado: $state"
[ -n "$online" ] && echo "Entrada (Mains) online: $online"
[ -n "$erate" ] && echo "Potência (UPower): ${erate} W"
[ -n "$p_sysfs" ] && echo "Potência (sysfs): ${p_sysfs} W"
[ -n "$v_v" ] && echo "Tensão (sysfs): ${v_v} V"
[ -n "$i_ma" ] && echo "Corrente (sysfs): ${i_ma} mA"
[ -n "$voltage_up" ] && echo "Tensão (UPower): ${voltage_up} V"
[ -n "$ttfull" ] && echo "Tempo p/ 100%: $ttfull"
[ -n "$ttempty" ] && echo "Tempo p/ 0%: $ttempty"
[ -n "$SYS_BAT" ] && echo "Abrir pasta sysfs | bash='xdg-open $SYS_BAT' terminal=false"
echo "Abrir Configurações de Energia | bash='gnome-control-center power' terminal=false"
