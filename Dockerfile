FROM php:7.0-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    vim \
    wget \
    nano \
    unzip \
    libxslt-dev \
    bash 

# Install MCrypt
RUN apt-get update \
    && apt-get install -y libmcrypt-dev \
    && docker-php-ext-install mcrypt

# SSL Certification upload
COPY ./ssl-certificate/mycert.crt /etc/apache2/mycert.crt
COPY ./ssl-certificate/mycert.key /etc/apache2/mycert.key
RUN chmod 777 /etc/apache2/mycert.crt && chmod 777 /etc/apache2/mycert.key

# Apache2 Set Up
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Config SSL Certification
RUN a2enmod rewrite && a2enmod ssl && a2enmod socache_shmcb
RUN sed -i '/SSLCertificateFile.*snakeoil\.pem/c\SSLCertificateFile \/etc\/apache2\/mycert.crt' /etc/apache2/sites-available/default-ssl.conf
RUN sed -i '/SSLCertificateKeyFile.*snakeoil\.key/cSSLCertificateKeyFile /etc/apache2/mycert.key/' /etc/apache2/sites-available/default-ssl.conf
# RUN a2ensite default-ssl
RUN service apache2 restart

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd xsl intl soap zip
    
# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Get Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

USER $user

# Set working directory
WORKDIR /var/www/html
