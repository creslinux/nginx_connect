#!/bin/sh
## Pre-Script to supervisord should any docker internals massaging be desired

# Check if user wants to run anything before. If file pre_start.sh exists, run this.
echo "Startig up `date`"
sleep 20 # Let other back end services startup 
date

if [ -f /pre_start.sh ]; then
   chmod +x /pre_start.sh
   bash /pre_start.sh
fi

chown -R nobody:nogroup /apps/
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
