FROM node:22-alpine

RUN mkdir -p /opt/app/weather-app

COPY . /opt/app/weather-app

WORKDIR /opt/app/weather-app

RUN npm install

EXPOSE 3000

CMD [ "npm", "start"]
