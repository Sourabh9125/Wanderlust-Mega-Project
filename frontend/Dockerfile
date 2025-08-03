#stage 1
FROM node:20 AS builder

WORKDIR /app

COPY package.*json ./

RUN npm install --development  && \
    npm cache clean --force && \
    rm -rf /tmp/*

COPY . . 

#stage 2

FROM node:20-slim

WORKDIR /app

COPY --from=builder /app ./
COPY  .env.docker .env 

EXPOSE 5173

CMD ["npm","run","dev", "--", "--host"]


