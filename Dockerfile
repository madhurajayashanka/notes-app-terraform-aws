FROM node:18.17

WORKDIR /app

COPY package.json /app/package.json

RUN npm install

COPY . /app

EXPOSE 5000

CMD ["npm","run", "start"]


