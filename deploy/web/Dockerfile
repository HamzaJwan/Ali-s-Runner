FROM nginx:1.28-alpine

COPY deploy/web/nginx.conf /etc/nginx/conf.d/default.conf
COPY builds/web_rc/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
