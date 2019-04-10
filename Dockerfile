FROM ubuntu:18.04
RUN apt-get -y update
RUN apt-get install -y curl supervisor git openssl build-essential libssl-dev wget vim curl \
 unzip autoconf libtool automake ed libpcre3 libpcre3-dev iputils-ping dnsutils net-tools tcpdump \ 
 zlibc zlib1g zlib1g-dev
WORKDIR /apps/ 
RUN wget -O  nginx-1.15.8.tar.gz http://nginx.org/download/nginx-1.15.8.tar.gz
RUN tar -zxvf nginx-1.15.8.tar.gz \
    && git clonse https://github.com/creslinux/ngx_http_proxy_connect_module.git \
    && cd nginx-1.15.8/ \
    && patch -p1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_101504.patch \
    && ./configure --add-module=../ngx_http_proxy_connect_module --with-http_ssl_module --with-http_gunzip_module --with-http_gzip_static_module  --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-file-aio --with-http_v2_module --with-ipv6 --with-http_realip_module --with-http_addition_module  --with-http_sub_module  --with-http_dav_module\
    && make \
    && make install \
    && cd /apps 
WORKDIR /
RUN openssl req  -new -newkey rsa:2048 -days 3650 -nodes -x509  -subj "/C=US/ST=rtmtb/L=rtmtb/O=Dis/CN=api.selfsigned.forward"  -keyout forward.key -out forward.crt && rm -rf /etc/nginx/nginx.conf
COPY init_and_run.sh /init_and_run.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE  3128
CMD ["/usr/bin/supervisord"]
