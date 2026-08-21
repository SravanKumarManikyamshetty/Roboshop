FROM node:20.0
WORKDIR /app
COPY package.json .
COPY *.js .
RUN npm install
EXPOSE 8080
ENV REDIS_HOST=redis \
    CATALOGUE_HOST=catalogue \
    CATALOGUE_PORT=8080
CMD ["node", "server.js"]