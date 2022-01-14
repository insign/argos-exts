#!/usr/bin/env bash

LOG_ENTRY=$(journalctl /usr/bin/gnome-shell -n 1 --output=cat --no-pager)
echo "<span color='#9BF' weight='normal'><small><tt>$LOG_ENTRY</tt></small></span> | length=40"

echo "---"
echo "View GNOME Shell Log | bash='journalctl /usr/bin/gnome-shell -f'"
