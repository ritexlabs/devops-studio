FROM node:22-alpine

RUN mkdir -p /opt/app/chat-app

COPY . /opt/app/chat-app

WORKDIR /opt/app/chat-app

RUN npm install

EXPOSE 3000

CMD [ "npm", "start"]
