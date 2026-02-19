# Strapi base image
FROM node:18-alpine

# Set working directory
WORKDIR /opt/app

# Copy files and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy source code
COPY . .

# Build Strapi
RUN npm run build

# Expose port (Instruction: 1337)
EXPOSE 1337

# Start Strapi
CMD ["npm", "run", "start"]