#!/bin/bash
#
# Bandwith test, using speedtest++, sivel/speedtest-cli or ookla speedtest CLI (needs jq)
# Needs xclip to copy to clipboard
# <bitbar.title>Bandwith test, using speedtest++, speedtest-cli or ookla speedtest CLI</bitbar.title>
# <bitbar.version>v1.1</bitbar.version>
# <bitbar.author>Hélio</bitbar.author>
# <bitbar.author.github>insign</bitbar.author.github>
# <bitbar.desc>Bandwith test, using speedtest++, speedtest-cli or ookla speedtest CLI</bitbar.desc>
# <bitbar.dependencies>speedtest++</bitbar.dependencies>
# <bitbar.dependencies>speedtest-cli</bitbar.dependencies>
# <bitbar.dependencies>speedtest</bitbar.dependencies>
# <bitbar.dependencies>xclip</bitbar.dependencies>
# <bitbar.dependencies>jq</bitbar.dependencies>

# Change as you prefer or leave empty/commented to TRY get the nearest server (many times buggy)
# SERVER_ID=10843 # currently works better with ookla speedtest cli

PATH=$PATH:$HOME/.local/bin
# shellcheck disable=SC2028


if [ "$1" = "share" ]; then
        # Copy  to the clipboard
        echo "$2" | xclip -selection clipboard
        $(which notify-send) 'Copied!' 'Sent to clipboard'
else
        if [[ -x "$(command -v speedtest++)" ]]; then
                OUTPUT=$($(command -v "speedtest++") --output json ${SERVER_ID:+--test-server=$SERVER_ID})
                DOWNLOAD=$(jq -r '.download' <<<"$OUTPUT" | awk '{printf "%.2f", $1 / 1e+6}')
                UPLOAD=$(jq -r '.upload' <<<"$OUTPUT" | awk '{printf "%.2f", $1 / 1e+6}')
                PING=$(jq -r '.ping' <<<"$OUTPUT")
                IP=$(jq -r '.client.ip' <<<"$OUTPUT")
                ISP=$(jq -r '.client.isp' <<<"$OUTPUT")
                SERVER=$(jq '.server | .name + ", " + .sponsor' -r <<<"$OUTPUT")
                MAP=$(jq -r '.server | .name + ", " + .sponsor' <<<"$OUTPUT" | jq -sRr @uri)

                echo "${DOWNLOAD%%.*} Mbps | refresh=true"
                echo '---'
                echo "$ISP\n$IP | terminal=false bash='$0' param1=share param2=$IP"
                echo "${DOWNLOAD%%.*} Mbps\t<i>download</i>"
                echo "\t\t${UPLOAD%%.*} Mbps\t<i>upload</i>"
                echo "\t\t${PING%%.*} ms\t\t<i>ping</i>"
                echo "$SERVER | href=https://google.com/maps?q=$MAP"
                echo "Test again | refresh=true"
        elif [[ -x "$(command -v speedtest-cli)" ]]; then
                OUTPUT=$($(command -v "speedtest-cli") --json --share ${SERVER_ID:+--server=$SERVER_ID})
                DOWNLOAD=$(jq '.download / 1e+6' <<<"$OUTPUT")
                UPLOAD=$(jq '.upload / 1e+6' <<<"$OUTPUT")
                PING=$(jq '.ping' <<<"$OUTPUT")
                IP=$(jq -r '.client.ip' <<<"$OUTPUT")
                ISP=$(jq -r '.client.isp' <<<"$OUTPUT")
                SHARE=$(jq '.share' -r <<<"$OUTPUT")
                SERVER=$(jq '.server | .name + ", " + .cc' -r <<<"$OUTPUT")
                MAP=$(jq -r '.server | .name + ", " + .cc' <<<"$OUTPUT" | jq -sRr @uri)

                echo "${DOWNLOAD%%.*}" Mbps
                echo '---'
                echo "$ISP\n$IP | terminal=false bash='$0' param1=share param2=$IP"
                echo "${DOWNLOAD%%.*} Mbps\t<i>download</i>"
                echo "\t\t${UPLOAD%%.*} Mbps\t<i>upload</i>"
                echo "\t\t${PING%%.*} ms\t\t<i>ping</i>"
                echo "$SERVER | href=https://google.com/maps?q=$MAP"
                echo "Share result | terminal=false bash='$0' param1=share param2=$SHARE"
                echo "Open result | href=$SHARE"
                echo "Test again | refresh=true"
        elif [ -x "$(command -v speedtest)" ]; then
                OUTPUT=$($(command -v "speedtest") --format=json ${SERVER_ID:+--server-id=$SERVER_ID})
                DOWNLOAD=$(jq '.download.bandwidth / 125000' <<<"$OUTPUT")
                UPLOAD=$(jq '.upload.bandwidth / 125000' <<<"$OUTPUT")
                PING=$(jq '.ping.latency' <<<"$OUTPUT")
                IP=$(jq -r '.interface.externalIp' <<<"$OUTPUT")
                ISP=$(jq -r '.isp' <<<"$OUTPUT")
                SHARE=$(jq '.result.url' -r <<<"$OUTPUT")
                SERVER=$(jq '.server | .name + ", " + .location' -r <<<"$OUTPUT")
                MAP=$(jq -r '.server | .name + ", " + .location' <<<"$OUTPUT" | jq -sRr @uri)

                echo "${DOWNLOAD%%.*} Mbps | refresh=true"
                echo '---'
                echo "$ISP\n$IP | terminal=false bash='$0' param1=share param2=$IP"
                echo "${DOWNLOAD%%.*} Mbps\t<i>download</i>"
                echo "\t\t${UPLOAD%%.*} Mbps\t<i>upload</i>"
                echo "\t\t${PING%%.*} ms\t\t<i>ping</i>"
                echo "$SERVER | href=https://google.com/maps?q=$MAP"
                echo "Share result | terminal=false bash='$0' param1=share param2=$SHARE"
                echo "Open result | href=$SHARE"
                echo "Test again | refresh=true"
        else
                echo ~$USER 'no speedtest CLI found'

        fi
fi
