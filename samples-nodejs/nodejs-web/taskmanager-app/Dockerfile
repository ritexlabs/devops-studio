FROM node:22-alpine

RUN mkdir -p /opt/app/taskmanager-app

COPY . /opt/app/taskmanager-app

WORKDIR /opt/app/taskmanager-app

RUN npm install

EXPOSE 3000

CMD [ "npm", "start"]
