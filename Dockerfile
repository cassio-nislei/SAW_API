FROM php:8.2-apache

# Instalar dependências do sistema e extensões PHP
RUN apt-get update && apt-get install -y \
    libgd-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev && \
    rm -rf /var/lib/apt/lists/*

# Instalar extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd mysqli pdo pdo_mysql && \
    docker-php-ext-enable gd mysqli pdo pdo_mysql

# Habilitar mod_rewrite para URLs amigáveis
RUN a2enmod rewrite

# Copiar o código para o Apache
COPY . /var/www/html/

# Configurar php.ini para melhor performance e compatibilidade
RUN echo "display_errors = On" >> /usr/local/etc/php/conf.d/errorhandling.ini && \
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/errorhandling.ini && \
    echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/performance.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/performance.ini

# Dar permissão ao Apache
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expor porta 80
EXPOSE 80

# Comando padrão
CMD ["apache2-foreground"]
