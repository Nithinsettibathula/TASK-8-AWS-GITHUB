FROM node:18-alpine

# Installing necessary build tools for Strapi and Sharp
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1

WORKDIR /opt/app

# Copy package files
COPY package*.json ./

# Run install with clean slate
RUN npm install

# Copy source code
COPY . .

# Build Strapi
RUN npm run build

# Expose port (Instruction: 1337)
EXPOSE 1337

# Start Strapi
CMD ["npm", "run", "start"]