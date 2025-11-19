FROM php:8.2-apache

# Instalar dependências e extensão mysqli
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Copiar o código para o Apache
COPY . /var/www/html/

# Dar permissão ao Apache
RUN chown -R www-data:www-data /var/www/html
