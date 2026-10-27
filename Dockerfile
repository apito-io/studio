FROM alpine:3.20

RUN apk add --no-cache nginx ca-certificates wget openssl

WORKDIR /opt/apito

# Engine env and console env are mounted by `apito start` from ~/.apito/bin.
ARG TARGETARCH=amd64
COPY engine/apito-engine-${TARGETARCH} ./engine
RUN chmod +x ./engine

COPY console/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV SERVE_PORT=5055
EXPOSE 4055 5055

ENTRYPOINT ["/docker-entrypoint.sh"]
