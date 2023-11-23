FROM node:16

WORKDIR /app

COPY package.json ./
RUN npm install

COPY index.js ./

EXPOSE 3000

CMD ["node", "index.js"]