FROM php:8.3-apache
LABEL author="Estima"

# Arguments defined in docker-compose.yml
ARG domain
ARG user
ARG uid

# SSL Certification upload
RUN cd /etc/apache2 \ 
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mycert.key -out mycert.crt -subj "/CN=$domain"
RUN chmod 777 /etc/apache2/mycert.crt && chmod 777 /etc/apache2/mycert.key

RUN echo "ServerName $domain" >> /etc/apache2/apache2.conf
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Config SSL Certification
RUN a2enmod ssl && a2enmod socache_shmcb
RUN sed -i '/SSLCertificateFile.*snakeoil\.pem/c\SSLCertificateFile \/etc\/apache2\/mycert.crt' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i '/SSLCertificateKeyFile.*snakeoil\.key/cSSLCertificateKeyFile /etc/apache2/mycert.key' /etc/apache2/sites-available/default-ssl.conf
RUN a2ensite default-ssl
RUN a2enmod rewrite

# Install Composer
RUN curl -o /usr/local/bin/composer https://getcomposer.org/download/latest-stable/composer.phar \
    && chmod +x /usr/local/bin/composer

# Install system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    sudo \
    git-all \
    zip \
    unzip \
    wget \
    bash \
    nano \
    nodejs \
    npm \
    libfreetype6-dev libicu-dev libjpeg62-turbo-dev libpng-dev libpq-dev \
    libsasl2-dev libssl-dev libwebp-dev libxpm-dev libzip-dev libzstd-dev \ 
    libxml2-dev libonig-dev libgd-dev libxslt-dev zlib1g-dev 

# Clear cache
RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install PHP extensions
RUN pecl install --configureoptions='enable-redis-igbinary="yes" enable-redis-lzf="yes" enable-redis-zstd="yes"' igbinary zstd redis 
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-xpm
RUN docker-php-ext-install gd intl pdo_mysql zip mbstring exif pcntl bcmath xsl
RUN docker-php-ext-enable igbinary opcache redis zstd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user
    
# Add the user to the sudo group and remove the password requirement
RUN usermod -aG sudo $user
RUN echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user \
    && chmod 0440 /etc/sudoers.d/$user

# Set bash as default shell (works in vscode)
RUN chsh -s /bin/bash $user

# Change current user to $user
USER $user

# Install nvm and set the nvm command
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.bashrc" \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$HOME/.bashrc" \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$HOME/.bashrc"
