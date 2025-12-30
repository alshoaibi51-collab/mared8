# Use Node.js LTS version
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy app source code
COPY . .

# Expose port
EXPOSE 3000

# Start the server
CMD [ "node", "server.js" ]