FROM node:20.20.0-alpine3.22 AS builder
WORKDIR /app
COPY package.json .
COPY *.js .
RUN npm install

FROM node:20.20.0-alpine3.22 
EXPOSE 8080
WORKDIR /app
COPY --from=builder /app /app
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop && chown -R roboshop:roboshop /app
USER roboshop
CMD ["node", "server.js"]

