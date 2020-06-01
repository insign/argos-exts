#!/bin/bash

# <bitbar.title>external-ipv4-ipv6</bitbar.title>
# <bitbar.author>Hélio</bitbar.author>
# <bitbar.author.github>insign</bitbar.author.github>
# <bitbar.desc>Gets the current external IPv4 and IPv6 address. And click-to-copy</bitbar.desc>
# <bitbar.dependencies>xclip</bitbar.dependencies>



if [ "$1" = "copy" ]; then
  # Copy the IP to clipboard
  echo -n "$2" | xclip -selection clipboard
  $(which notify-send) 'Copied!' 'Sent to clipboard'
else
	EXTERNAL_IPv4=$(curl ipv4.icanhazip.com)
	EXTERNAL_IPv6=$(curl ipv6.icanhazip.com)
fi

echo "$EXTERNAL_IPv4"
echo "---"
echo "$EXTERNAL_IPv4 | terminal=false bash='$0' param1=copy param2=$EXTERNAL_IPv4"
echo "$EXTERNAL_IPv6 | terminal=false bash='$0' param1=copy param2=$EXTERNAL_IPv6"

