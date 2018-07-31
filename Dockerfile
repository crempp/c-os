FROM node:9.11.1

WORKDIR /app
COPY ./pcjs /app

RUN npm install -g http-server

EXPOSE 8080

# Launch application
CMD ["http-server"]
