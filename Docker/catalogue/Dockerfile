FROM node:20.0
WORKDIR /app
COPY package.json .
COPY *.js .
RUN npm install
EXPOSE 8080
ENV MONGO="true" \
   MONGO_URL="mongodb://mongodb:27017/catalogue"
CMD ["node", "server.js"]