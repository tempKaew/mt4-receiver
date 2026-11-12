FROM node:26-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./
RUN npm install --omit=dev

# Copy application code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Start the server (includes batch worker)
CMD ["node", "server.js"]
