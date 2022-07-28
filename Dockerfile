FROM node:17.1.0 as builder

RUN sed -i s@/deb.debian.org/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.debian.org/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get update && apt-get install -y python3 python libvips-dev glib2.0-dev --no-install-recommends


COPY package.json /tmp/package.json
RUN npm config set registry https://registry.npm.taobao.org
RUN cd /tmp && npm install
RUN mkdir -p /app/im && cp -a /tmp/node_modules /app/im/

WORKDIR /app/im
ENV NODE_OPTIONS=--openssl-legacy-provider
COPY . /app/im
EXPOSE 3000
RUN npm run build:renderer

FROM nginx

RUN rm /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/nginx.conf
COPY --from=builder /app/im/build/  /usr/share/nginx/html/
COPY --from=builder /app/im/nginx.default.conf /etc/nginx/nginx.conf

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
