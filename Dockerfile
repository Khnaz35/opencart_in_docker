# Base image with PHP-FPM
FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zlib1g-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Clean up APT cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the default working directory
WORKDIR /var/www/html

# Arguments for dynamic version control
ARG VERSION=""
ENV SRC_FOLDER="/var/www/html"

# Download and extract OpenCart directly to /var/www/html if not already present
RUN mkdir -p "$SRC_FOLDER" && \
    if [ -z "$(ls -A $SRC_FOLDER)" ]; then \
    echo "Downloading OpenCart..." && \
    if [ -z "$VERSION" ]; then \
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/opencart/opencart/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4); \
    else \
    DOWNLOAD_URL="https://github.com/opencart/opencart/releases/download/$VERSION/opencart-$VERSION.zip"; \
    fi && \
    echo "Download URL: $DOWNLOAD_URL" && \
    curl -Lo /tmp/opencart.zip "$DOWNLOAD_URL" && \
    unzip /tmp/opencart.zip -d /tmp/opencart && \
    cp -r /tmp/opencart/upload/* "$SRC_FOLDER" && \
    echo "Contents of $SRC_FOLDER after copy:" && \
    ls -A "$SRC_FOLDER" && \
    rm -rf /tmp/opencart /tmp/opencart.zip; \
    else \
    echo "$SRC_FOLDER already contains files, skipping download."; \
    fi

# Set permissions for the web server
RUN chown -R www-data:www-data /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Run PHP-FPM server
CMD ["php-fpm"]
