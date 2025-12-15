#!/bin/bash
# <bitbar.title>Conn Checker</bitbar.title>
# <bitbar.author>Hélio</bitbar.author>
# <bitbar.author.github>insign</bitbar.author.github>
# <bitbar.desc>Gets the status of connection and DNS-over-TLS/DNS-over-HTTPS/DNSCrypt</bitbar.desc>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.dependencies>xclip</bitbar.dependencies>
# <bitbar.dependencies>jq</bitbar.dependencies>
# <bitbar.dependencies>uuidgen</bitbar.dependencies>

titles=()
subtitles=()

from_cf_warp() {
	# shellcheck disable=SC1090
	source <(curl --silent https://1.1.1.1/cdn-cgi/trace | sed -e 's/^/local /')

	# shellcheck disable=SC2154
	if [[ "$warp" == 'on' ]]; then
		foundStatus=true
		titles+=(' | iconName=weather-overcast-symbolic | color=#F48120')

		subtitles+=("<b>WARP</b> VPN\t\t<u>$colo</u> | href=https://google.com/maps?q=$colo+airport")
	fi
}

from_nextdns() {
	json=$(curl -L --silent "https://test.nextdns.io/")
	status=$(jq '.status' <<<"$json")
	protocol=$(jq '.protocol' <<<"$json")
	# deviceName=$(jq '.deviceName' <<<"$json")
	if [[ "$status" == '"ok"' ]]; then
		foundStatus=1
		titles+=(" | iconName=security-high-symbolic | color=#007BFF")
		subtitles+=("NextDNS\t\t${protocol//\"/} | href=https://my.nextdns.io")
	fi
}

from_cf_dns() {
	http_code=$(curl -o /dev/null --silent --write-out '%{http_code}\n' "$3")
	if [[ "$http_code" == "200" ]]; then
		foundStatus=1
		titles+=("$1")
		subtitles+=("$2")
	fi
}

from_adguard() {
	http_code=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "$3")
	if [[ "$http_code" == "200" ]]; then
		foundStatus=1
		titles+=("$1")
		titles+=("$2")
	fi
}

from_tailscale() {
	if command -v tailscale &>/dev/null; then
		json=$(tailscale status --json 2>/dev/null)
		if [[ -n "$json" ]]; then
			state=$(jq -r '.BackendState' <<<"$json")
			if [[ "$state" == "Running" ]]; then
				foundStatus=1
				relay=$(jq -r '.Self.Relay // "direct"' <<<"$json")
				hostname=$(jq -r '.Self.HostName' <<<"$json")
				tailscale_ip=$(jq -r '.TailscaleIPs[0] // ""' <<<"$json")
				
				titles+=(" | iconName=web-browser-symbolic | color=#00B4D8")
				subtitles+=("<b>Tailscale</b>\\t\\t<u>$relay</u> ($hostname) | href=https://login.tailscale.com/admin/machines")
				if [[ -n "$tailscale_ip" ]]; then
					subtitles+=("IP: $tailscale_ip | terminal=false bash=-c 'echo -n $tailscale_ip | xclip -selection clipboard'")
				fi
			fi
		fi
	fi
}

from_cf_warp

from_tailscale

from_nextdns

if [[ "$warp" == "on" ]]; then
	foundStatus=1
	titles+=('1⁴ DNS')
	subtitles+=("1.1.1.1 DNS\t\t<i>WARP</i><u>$colo</u> | href=https://google.com/maps?q=$colo+airport")
	exit 0
else
	# call my personal dyndns
	curl -s https://www.duckdns.org/update\?domains\=estrelas\&token\=feea405d-fe94-4a10-bd17-9723b0ba8c55 >/dev/null
	curl -s https://link-ip.nextdns.io/a4a476/e00e172e849904d3 >/dev/null

	from_cf_dns '1⁴ DNS' '1.1.1.1 DNS\t\t<i>DoT</i>' 'https://is-dot.help.every1dns.net/resolvertest'
	from_cf_dns '1⁴ DNS' '1.1.1.1 DNS\t\t<i>DoH</i>' 'https://is-doh.help.every1dns.net/resolvertest'
	from_cf_dns '1⁴ DNS' '1.1.1.1 DNS\t\t<i>Standard</i>' 'https://is-cf.help.every1dns.net/resolvertest'
fi

if [[ -z $foundStatus ]]; then
	from_adguard 'AdGuard' 'AdGuard DNS <b>Standard</b>' 'https://1590966205380-dns-standard-dnscheck.adguard.com/info.json'
	from_adguard 'DoT' 'AdGuard <b>DNS-over-TLS</b>' 'https://1588629318930-dot-standard-dnscheck.adguard.com/info.json'
	from_adguard 'DoH' 'AdGuard <b>DNS-over-HTTPS</b>' 'https://1590966205381-doh-standard-dnscheck.adguard.com/info.json'
	from_adguard 'DNSCrypt' 'AdGuard <b>DNSCrypt</b>' 'https://1590966205383-dnscrypt-standard-dnscheck.adguard.com/info.json'

	from_adguard 'Family' 'AdGuard Family DNS <b>Standard</b>' 'https://1590966205384-dns-family-dnscheck.adguard.com/info.json'
	from_adguard 'DoT Family' 'AdGuard Family <b>DNS-over-TLS</b>' 'https://1590966205386-dot-family-dnscheck.adguard.com/info.json'
	from_adguard 'DoH Family' 'AdGuard Family <b>DNS-over-HTTPS</b>' 'https://1590966205385-doh-family-dnscheck.adguard.com/info.json'
	from_adguard 'DNSC Family' 'AdGuard Family <b>DNSCrypt</b>' 'https://1590966205387-dnscrypt-family-dnscheck.adguard.com/info.json'

	from_adguard 'DNS' 'AdGuard No-Filter DNS' 'https://1590966205388-dns-unfiltered-dnscheck.adguard.com/info.json'
	from_adguard 'DoT NF' 'AdGuard No-Filter <b>DNS-over-TLS</b>' 'https://1590966205389-doh-unfiltered-dnscheck.adguard.com/info.json'
	from_adguard 'DoH NF' 'AdGuard No-Filter <b>DNS-over-HTTPS</b>' 'https://1590966205390-dot-unfiltered-dnscheck.adguard.com/info.json'
	from_adguard 'DNSC NF' 'AdGuard No-Filter <b>DNSCrypt</b>' 'https://1590966205392-dnscrypt-unfiltered-dnscheck.adguard.com/info.json'
fi

if [[ -z $foundStatus ]]; then
	echo 'unknown'
	echo "---"
	echo 'Looks your are using another DNS service'
else
	echo "${titles[0]}"
	echo '---'

	for subtitle in "${subtitles[@]}"; do
		echo "$subtitle"
	done
fi
