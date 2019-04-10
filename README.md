# nginx_connect - Dockerised.

A patched nginx to accept CONNECT headers, as if its a forward proxy. 
This build makes use of the work of @chobits
Github page: https://github.com/chobits/ngx_http_proxy_connect_module

In a simple incarnation the following nginx_config will accept a CONNECT header and send on to a reverse proxy as if a normaly HTTP/S request. Please see linked @Chobits page for the full, original, and much better docu.

In this instance the next hop reverse proxy being 10.10.10.10:8080

An alternative can be to set $host for proxy_pass target, this will then connect to originserver - Google as example - directly. In effect a simple ` CONNECT <> HTTP/S ` pipe for proxied clients with no proxy.

I use this for an app that makes outbound connections via Proxy CONNECT requests to a remote API, I want to put a reverse proxy in-line to cache responses for small period of time. 

`Client > CONNECT > nginx_connect > HTTP/S Get > nginx_reverse(caching) > HTTP/S Get(internet) > Remote API server`

Squid can act as Forward proxy and with bump offer the same. However i found sqids minimum cache time of 1 minute to be far outside acceptable, as my use-case i wish to often only cache for 1 second. Im mainly protecting against 100's of clients wanting the same data in the same 1 second moment. 

nginx_conf example. Volume mount as `/etc/nginx/nginx.conf`
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
