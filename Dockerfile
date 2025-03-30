
FROM node:18

WORKDIR /app

# Copy package.json and package-lock.json first (for caching dependencies)
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the application files
COPY . .

# Expose the application port (change if needed)
EXPOSE 3000

# Start the application
CMD ["node", "app.js"]