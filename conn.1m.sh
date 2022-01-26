#!/bin/bash
# <bitbar.title>AdGuard Checker</bitbar.title>
# <bitbar.author>Hélio</bitbar.author>
# <bitbar.author.github>insign</bitbar.author.github>
# <bitbar.desc>Gets the status AdGuard Standard/DNS-over-TLS/DNS-over-HTTPS/DNSCrypt</bitbar.desc>
# <bitbar.version>1.0</bitbar.version>
#

from_cloudflare_warp() {
	# shellcheck disable=SC1090
	source <(curl -s https://1.1.1.1/cdn-cgi/trace | sed -e 's/^/local /')

  # shellcheck disable=SC2154
  if [[ "$warp" == "on" ]]; then
    echo "WARP $colo"
    echo "---"
    echo "Cloudflare VPN <b>WARP</b>"
    echo "Region: $colo | href=https://google.com/maps?q=$colo+airport"
    exit
  fi
}

from_head_with_body() {
  http_code=$(curl -o /dev/null --silent --write-out '%{http_code}\n' "$3")
  if [[ "$http_code" == "200" ]]; then
    echo "$1"
    echo "---"
    echo "$2"
    exit
  fi
}

from_head() {
  http_code=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "$3")
  if [[ "$http_code" == "200" ]]; then
    echo "$1"
    echo "---"
    echo "$2"
    exit
  fi
}

from_cloudflare_warp

from_head_with_body '1⁴' 'Cloudflare 1⁴ DNS <b>DoT</b>' 'https://is-dot.help.every1dns.net/resolvertest'
from_head_with_body '1⁴' 'Cloudflare 1⁴ DNS <b>DoH</b>' 'https://is-doh.help.every1dns.net/resolvertest'
from_head_with_body '1⁴' 'Cloudflare 1⁴ DNS <b>Standard</b>' 'https://is-cf.help.every1dns.net/resolvertest'

from_head 'AdGuard' 'AdGuard DNS <b>Standard</b>' 'https://1590966205380-dns-standard-dnscheck.adguard.com/info.json'
from_head 'DoT' 'AdGuard <b>DNS-over-TLS</b>' 'https://1588629318930-dot-standard-dnscheck.adguard.com/info.json'
from_head 'DoH' 'AdGuard <b>DNS-over-HTTPS</b>' 'https://1590966205381-doh-standard-dnscheck.adguard.com/info.json'
from_head 'DNSCrypt' 'AdGuard <b>DNSCrypt</b>' 'https://1590966205383-dnscrypt-standard-dnscheck.adguard.com/info.json'

from_head 'Family' 'AdGuard Family DNS <b>Standard</b>' 'https://1590966205384-dns-family-dnscheck.adguard.com/info.json'
from_head 'DoT Family' 'AdGuard Family <b>DNS-over-TLS</b>' 'https://1590966205386-dot-family-dnscheck.adguard.com/info.json'
from_head 'DoH Family' 'AdGuard Family <b>DNS-over-HTTPS</b>' 'https://1590966205385-doh-family-dnscheck.adguard.com/info.json'
from_head 'DNSC Family' 'AdGuard Family <b>DNSCrypt</b>' 'https://1590966205387-dnscrypt-family-dnscheck.adguard.com/info.json'

from_head 'DNS' 'AdGuard No-Filter DNS' 'https://1590966205388-dns-unfiltered-dnscheck.adguard.com/info.json'
from_head 'DoT NF' 'AdGuard No-Filter <b>DNS-over-TLS</b>' 'https://1590966205389-doh-unfiltered-dnscheck.adguard.com/info.json'
from_head 'DoH NF' 'AdGuard No-Filter <b>DNS-over-HTTPS</b>' 'https://1590966205390-dot-unfiltered-dnscheck.adguard.com/info.json'
from_head 'DNSC NF' 'AdGuard No-Filter <b>DNSCrypt</b>' 'https://1590966205392-dnscrypt-unfiltered-dnscheck.adguard.com/info.json'

from_head "none" 'Looks your are using another DNS service' 'https://example.com'

echo 'unknown'
