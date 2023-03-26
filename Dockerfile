FROM node:19-alpine3.16

RUN mkdir /express
WORKDIR /express
COPY ./ /express/

RUN npm install
EXPOSE 3000

CMD ["node","examples/hello-world"]
