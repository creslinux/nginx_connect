# nginx_connect

A patched nginx to accept CONNECT headers, as if its a forward proxy. 

In a simple incarnation the following will accept a CONNECT header and send on to a reverse proxy as if a normaly HTTP/S request. 

In this instance the next hop reverse proxt being 10.10.10.10:8080

I use this for an app that makes outbound connections via Proxy CONNECT requests to a remote API, I want to put a reverse proxy in-line to cache responses for small period of time. 

`Client > CONNECT > nginx_connect > HTTP/S Get > nginx_reverse(caching) > HTTP/S Get(internet) > Remote API server`

Squid can act as Forward proxy and with bump offer the same. However i found sqids minimum cache time of 1 minute to be far outside acceptable, as my use-case i wish to often only cache for 1 second. Im mainly protecting against 100's of clients wanting the same data in the same 1 second moment. 

```
worker_processes  1;
events {
    worker_connections  1024;
}

http {
    error_log /etc/nginx/error_log.log warn;
    client_max_body_size 20m;

    resolver 127.0.0.11 ipv6=off;


    server {
        ##
        # Default server.

        listen                         3128;

        # dns resolver used by forward proxying
        resolver                       127.0.0.11 ipv6=off;

        # forward proxy for CONNECT request
        proxy_connect;
        proxy_connect_allow            443 3443;
        proxy_connect_connect_timeout  10s;
        proxy_connect_read_timeout     10s;
        proxy_connect_send_timeout     10s;
        proxy_connect_address 10.10.115.22:3007 ;

        # forward proxy for non-CONNECT request
        location / {
            proxy_pass  https://10.10.10.10:8080 ;
            proxy_set_header Host $http_host;
         }
    }
}
```
