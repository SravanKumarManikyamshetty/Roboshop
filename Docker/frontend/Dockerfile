FROM nginx:mainline-alpine3.24-slim AS builder
RUN rm -rf /usr/share/nginx/html/* 
RUN rm -rf /etc/nginx/nginx.conf
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY web/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

