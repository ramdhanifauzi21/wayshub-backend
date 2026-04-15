FROM node:12-alpine AS builder
WORKDIR /home/app
COPY package*.json ./
RUN npm install
COPY . .
 
FROM node:12-alpine
WORKDIR /home/app
COPY --from=builder /home/app .
EXPOSE 5000
CMD ["node", "index.js"]
