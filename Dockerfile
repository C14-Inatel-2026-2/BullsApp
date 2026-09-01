# Stage 1: Build stage
FROM dart:3.9 AS builder

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter repository and checkout stable version
RUN git clone https://github.com/flutter/flutter.git /flutter && \
    cd /flutter && \
    git checkout stable && \
    /flutter/bin/flutter config --no-analytics && \
    /flutter/bin/flutter precache

ENV PATH="/flutter/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy entire project
COPY . .

# Build web release
RUN flutter build web --release --no-tree-shake-icons --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/

# Stage 2: Runtime stage
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/

# Copy built web app from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/index.html || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
