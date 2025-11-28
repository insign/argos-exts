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

# Cache file to store last result
CACHE_FILE="/tmp/argos-speedtest-cache"
LOCK_FILE="/tmp/argos-speedtest-lock"

# Function to run speedtest and cache result
run_speedtest() {
	# Create lock file to indicate test is running
	touch "$LOCK_FILE"

	# Run the actual speedtest and save to cache
	if [[ -x "$(command -v speedtest++)" ]]; then
		OUTPUT=$($(command -v "speedtest++") --output json ${SERVER_ID:+--test-server=$SERVER_ID})
		echo "$OUTPUT" > "$CACHE_FILE"
	elif [[ -x "$(command -v speedtest-cli)" ]]; then
		OUTPUT=$($(command -v "speedtest-cli") --json --share ${SERVER_ID:+--server=$SERVER_ID})
		echo "$OUTPUT" > "$CACHE_FILE"
	elif [ -x "$(command -v speedtest)" ]; then
		OUTPUT=$($(command -v "speedtest") --format=json ${SERVER_ID:+--server-id=$SERVER_ID})
		echo "$OUTPUT" > "$CACHE_FILE"
	fi

	# Remove lock file
	rm -f "$LOCK_FILE"
}

if [ "$1" = "share" ]; then
        # Copy  to the clipboard
        echo "$2" | xclip -selection clipboard
        $(which notify-send) 'Copied!' 'Sent to clipboard'
elif [ "$1" = "run" ]; then
        # Run speedtest in background
        run_speedtest &
        exit 0
else
        # Check if test is currently running
        if [ -f "$LOCK_FILE" ]; then
                echo "Testing... | iconName=content-loading-symbolic"
                echo "---"
                echo "Running speedtest..."
                echo "Please wait | iconName=content-loading-symbolic"
                exit 0
        fi

        # Check if cache exists and is fresh (less than 1 hour old)
        if [ -f "$CACHE_FILE" ]; then
                CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
                if [ $CACHE_AGE -lt 3600 ]; then
                        # Use cached result
                        OUTPUT=$(cat "$CACHE_FILE")
                else
                        # Cache is stale, trigger new test in background
                        run_speedtest &
                        # Show old data while refreshing
                        OUTPUT=$(cat "$CACHE_FILE")
                fi
        else
                # No cache, run test in background and show loading
                run_speedtest &
                echo "Testing... | iconName=content-loading-symbolic refresh=true"
                echo "---"
                echo "Running first speedtest..."
                echo "This may take a few seconds | iconName=content-loading-symbolic"
                echo "Test again | refresh=true"
                exit 0
        fi

        # Detect which speedtest tool was used for the cached result
        if echo "$OUTPUT" | jq -e '.client' >/dev/null 2>&1; then
                # speedtest++ or speedtest-cli format
                if echo "$OUTPUT" | jq -e '.client.ip' >/dev/null 2>&1; then
                        # speedtest++ format
                        DOWNLOAD=$(jq -r '.download' <<<"$OUTPUT" | awk '{printf "%.2f", $1 / 1e+6}')
                        UPLOAD=$(jq -r '.upload' <<<"$OUTPUT" | awk '{printf "%.2f", $1 / 1e+6}')
                        PING=$(jq -r '.ping' <<<"$OUTPUT")
                        IP=$(jq -r '.client.ip' <<<"$OUTPUT")
                        ISP=$(jq -r '.client.isp' <<<"$OUTPUT")
                        SERVER=$(jq '.server | .name + ", " + .sponsor' -r <<<"$OUTPUT")
                        MAP=$(jq -r '.server | .name + ", " + .sponsor' <<<"$OUTPUT" | jq -sRr @uri)
                        SHARE=""
                else
                        # speedtest-cli format
                        DOWNLOAD=$(jq '.download / 1e+6' <<<"$OUTPUT")
                        UPLOAD=$(jq '.upload / 1e+6' <<<"$OUTPUT")
                        PING=$(jq '.ping' <<<"$OUTPUT")
                        IP=$(jq -r '.client.ip' <<<"$OUTPUT")
                        ISP=$(jq -r '.client.isp' <<<"$OUTPUT")
                        SHARE=$(jq '.share' -r <<<"$OUTPUT")
                        SERVER=$(jq '.server | .name + ", " + .cc' -r <<<"$OUTPUT")
                        MAP=$(jq -r '.server | .name + ", " + .cc' <<<"$OUTPUT" | jq -sRr @uri)
                fi
        else
                # ookla speedtest format
                DOWNLOAD=$(jq '.download.bandwidth / 125000' <<<"$OUTPUT")
                UPLOAD=$(jq '.upload.bandwidth / 125000' <<<"$OUTPUT")
                PING=$(jq '.ping.latency' <<<"$OUTPUT")
                IP=$(jq -r '.interface.externalIp' <<<"$OUTPUT")
                ISP=$(jq -r '.isp' <<<"$OUTPUT")
                SHARE=$(jq '.result.url' -r <<<"$OUTPUT")
                SERVER=$(jq '.server | .name + ", " + .location' -r <<<"$OUTPUT")
                MAP=$(jq -r '.server | .name + ", " + .location' <<<"$OUTPUT" | jq -sRr @uri)
        fi

        # Display results
        echo "${DOWNLOAD%%.*} Mbps | refresh=true"
        echo '---'
        echo "$ISP\n$IP | terminal=false bash='$0' param1=share param2=$IP"
        echo "${DOWNLOAD%%.*} Mbps\t<i>download</i>"
        echo "\t\t${UPLOAD%%.*} Mbps\t<i>upload</i>"
        echo "\t\t${PING%%.*} ms\t\t<i>ping</i>"
        echo "$SERVER | href=https://google.com/maps?q=$MAP"

        # Show share options if available
        if [ -n "$SHARE" ] && [ "$SHARE" != "null" ]; then
                echo "Share result | terminal=false bash='$0' param1=share param2=$SHARE"
                echo "Open result | href=$SHARE"
        fi

        # Test again button that triggers background run
        echo "Test again | terminal=false bash='$0' param1=run refresh=true"
fi
