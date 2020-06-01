#!/bin/bash
# <bitbar.title>AdGuard Checker</bitbar.title>
# <bitbar.author>Hélio</bitbar.author>
# <bitbar.author.github>insign</bitbar.author.github>
# <bitbar.desc>Gets the status AdGuard Standard/DNS-over-TLS/DNS-over-HTTPS/DNSCrypt</bitbar.desc>
# <bitbar.version>1.0</bitbar.version>
#


check_show() {
  ret=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "$3")
  if [[ "$ret" == "200" ]]; then
    echo $1
    echo "---"
    echo $2
    exit
  fi
}

check_show 'AdGuard' 'AdGuard DNS <b>Standard</b>' 'https://1590966205380-dns-standard-dnscheck.adguard.com/info.json'
check_show 'DoT' 'AdGuard <b>DNS-over-TLS</b>' 'https://1588629318930-dot-standard-dnscheck.adguard.com/info.json'
check_show 'DoH' 'AdGuard <b>DNS-over-HTTPS</b>' 'https://1590966205381-doh-standard-dnscheck.adguard.com/info.json'
check_show 'DNSCrypt' 'AdGuard <b>DNSCrypt</b>' 'https://1590966205383-dnscrypt-standard-dnscheck.adguard.com/info.json'

check_show 'Family' 'AdGuard Family DNS <b>Standard</b>' 'https://1590966205384-dns-family-dnscheck.adguard.com/info.json'
check_show 'DoT Family' 'AdGuard Family <b>DNS-over-TLS</b>' 'https://1590966205386-dot-family-dnscheck.adguard.com/info.json'
check_show 'DoH Family' 'AdGuard Family <b>DNS-over-HTTPS</b>' 'https://1590966205385-doh-family-dnscheck.adguard.com/info.json'
check_show 'DNSC Family' 'AdGuard Family <b>DNSCrypt</b>' 'https://1590966205387-dnscrypt-family-dnscheck.adguard.com/info.json'

check_show 'DNS' 'AdGuard No-Filter DNS' 'https://1590966205388-dns-unfiltered-dnscheck.adguard.com/info.json'
check_show 'DoT NF' 'AdGuard No-Filter <b>DNS-over-TLS</b>' 'https://1590966205389-doh-unfiltered-dnscheck.adguard.com/info.json'
check_show 'DoH NF' 'AdGuard No-Filter <b>DNS-over-HTTPS</b>' 'https://1590966205390-dot-unfiltered-dnscheck.adguard.com/info.json'
check_show 'DNSC NF' 'AdGuard No-Filter <b>DNSCrypt</b>' 'https://1590966205392-dnscrypt-unfiltered-dnscheck.adguard.com/info.json'

check_show 'none' 'Looks your are using another DNS service' 'https://example.com'

echo 'unknown'
