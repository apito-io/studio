FROM alpine:3.20

RUN apk add --no-cache nginx ca-certificates wget openssl

WORKDIR /opt/apito

COPY engine/apito-engine ./engine
COPY studio.env ./.env
RUN chmod +x ./engine

COPY console/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV SERVE_PORT=5050
EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
