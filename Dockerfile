# Use a lightweight Node.js image
FROM node:18

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package.json package-lock.json ./

# Install dependencies (avoid installing dev dependencies in production)
RUN npm install --only=production

# Copy the rest of the application files
COPY . .

# Expose the application port (update if your app runs on a different port)
EXPOSE 3000

# Start the application
CMD ["npm", "run", "start"]
