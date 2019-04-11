#!/bin/sh
## Pre-Script to supervisord should any docker internals massaging be desired

# Check if user wants to run anything before. If file pre_start.sh exists, run this.
sleep 2
if [ -f /pre_start.sh ]; then
   chmod +x /pre_start.sh
   bash /pre_start.sh
fi

# if there is not a nginx.conf at this point, move the template file to it. 
if [ ! -f /etc/nginx/nginx.conf ]; then
  cp /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf
fi 

chown -R nobody:nogroup /apps/
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
