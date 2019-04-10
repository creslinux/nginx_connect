#!/bin/sh
## Pre-Script to supervisord should any docker internals massaging be desired
chown -R nobody:nogroup /apps/
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
