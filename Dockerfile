FROM node:20-alpine AS builder

WORKDIR /usr/app-production

# Install build/runtime dependencies needed for native modules and ffmpeg-based features
RUN apk add --no-cache python3 make g++ ffmpeg

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Remove dev dependencies before copying into final image
RUN npm prune --production

FROM node:20-alpine

ENV NODE_ENV=production
ENV PORT=3000
ENV HTTP_PORT=3000
ENV HTTPS_PORT=8080
ENV FS_DIRECTORY=/data/
ENV TEMP_DIRECTORY=/temp/
ENV DOCKER=true

# Runtime dependencies
RUN apk add --no-cache ffmpeg

WORKDIR /usr/app-production

COPY --from=builder /usr/app-production ./

EXPOSE 3000
EXPOSE 8080

CMD ["npm", "run", "start"]
