FROM nginx:1.10

RUN rm /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/nginx.conf

COPY reverse-proxy.conf /etc/nginx/conf.d/reverse-proxy.conf
COPY nginx.* /etc/nginx/ssl/
COPY nginx.conf /etc/nginx/nginx.conf
COPY proxy-settings.conf /etc/nginx/conf.d/proxy-settings.conf

