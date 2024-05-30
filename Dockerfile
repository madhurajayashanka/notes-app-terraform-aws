FROM node:18.20.3-alpine3.20

WORKDIR /app

COPY package.json /app/package.json

RUN npm install

COPY . /app

EXPOSE 5000

CMD ["npm","run", "start"]


