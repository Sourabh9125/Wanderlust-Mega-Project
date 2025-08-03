#stage 1
FROM node:20 AS backend

WORKDIR /app

COPY package.*json ./

RUN npm install --development  && \
    npm cache clean --force && \
    rm -rf /tmp/*

COPY . .

#stage 2

FROM node:20-slim

WORKDIR /app

COPY --from=backend /app ./
COPY .env.docker .env

EXPOSE 8080

CMD ["npm","start"]
