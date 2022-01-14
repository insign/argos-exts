#!/bin/bash
#
# Bandwith test, using sivel/speedtest-cli or ookla speedtest CLI (best, needs to install jq)
# Needs xclip to copy to clipboard
# <bitbar.title>Bandwith test, using speedtest-cli or ookla speedtest CLI</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Hélio</bitbar.author>
# <bitbar.author.github>insign</bitbar.author.github>
# <bitbar.desc>Bandwith test, using speedtest-cli or ookla speedtest CLI</bitbar.desc>
# <bitbar.dependencies>speedtest-cli</bitbar.dependencies>
# <bitbar.dependencies>speedtest</bitbar.dependencies>
# <bitbar.dependencies>xclip</bitbar.dependencies>
# <bitbar.dependencies>jq</bitbar.dependencies>

# Change as you prefer or leave empty/commented to TRY get the nearest server (many times buggy)
# SERVER_ID=10843 # currently works better with ookla speedtest cli

PATH=$PATH:$HOME/.local/bin

if [ "$1" = "share" ]; then
        # Copy  to the clipboard
        echo "$2" | xclip -selection clipboard
        $(which notify-send) 'Copied!' 'Sent to clipboard'
else
        if [[ -x "$(command -v speedtest-cli)" ]]; then
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
