FROM php:8.2-apache

LABEL maintainer="SAW Development Team"
LABEL description="SAW Web Application with PHP 8.2 and Apache"

# ========================================
# 1. Instalar dependências do sistema e ferramentas build
# ========================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    zlib1g-dev \
    libgd-dev \
    git \
    curl \
    wget \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# ========================================
# 2. Instalar e habilitar extensões PHP
# ========================================
RUN docker-php-ext-configure gd \
        --with-freetype=/usr/include/freetype2 \
        --with-jpeg=/usr && \
    docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        zip \
        bcmath

# ========================================
# 3. Habilitar módulos Apache necessários
# ========================================
RUN a2enmod rewrite && \
    a2enmod headers && \
    a2enmod expires && \
    a2enmod deflate && \
    a2enmod ssl && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod remoteip && \
    a2enmod env

# ========================================
# 4. Copiar configurações Apache personalizadas
# ========================================
COPY apache-config.conf /etc/apache2/conf-available/saw-config.conf
RUN a2enconf saw-config

# ========================================
# 5. Configurar VirtualHost com suporte HTTPS
# ========================================
RUN cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerAdmin admin@saw.local
    DocumentRoot /var/www/html
    
    # Logs
    ErrorLog ${APACHE_LOG_DIR}/saw_error.log
    CustomLog ${APACHE_LOG_DIR}/saw_access.log combined
    
    # ProxyPreserveHost essencial para headers corretos
    ProxyPreserveHost On
    
    # Enable mod_rewrite
    <Directory /var/www/html>
        Options -MultiViews +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Cache control para browser preflight CORS
        <IfModule mod_headers.c>
            Header set Access-Control-Allow-Origin "*"
            Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
            Header set Access-Control-Allow-Headers "Content-Type, Authorization"
        </IfModule>
    </Directory>
</VirtualHost>
EOF

# ========================================
# 6. Configurar php.ini com valores otimizados
# ========================================
RUN echo "display_errors = On" >> /usr/local/etc/php/conf.d/errorhandling.ini && \
    echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/errorhandling.ini && \
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/errorhandling.ini && \
    echo "log_errors = On" >> /usr/local/etc/php/conf.d/errorhandling.ini

RUN echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_file_uploads = 100" >> /usr/local/etc/php/conf.d/uploads.ini

RUN echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/performance.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/performance.ini && \
    echo "default_socket_timeout = 60" >> /usr/local/etc/php/conf.d/performance.ini

RUN echo "session.gc_maxlifetime = 86400" >> /usr/local/etc/php/conf.d/session.ini && \
    echo "session.use_only_cookies = 1" >> /usr/local/etc/php/conf.d/session.ini && \
    echo "session.cookie_httponly = 1" >> /usr/local/etc/php/conf.d/session.ini && \
    echo "session.cookie_samesite = None" >> /usr/local/etc/php/conf.d/session.ini

# ========================================
# 7. Limpar ferramentas de build (reduz tamanho da imagem)
# ========================================
RUN apt-get remove --purge -y build-essential autoconf automake libtool pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ========================================
# 8. Criar diretórios necessários
# ========================================
RUN mkdir -p /var/www/html/logs && \
    mkdir -p /var/www/html/tmp && \
    mkdir -p /var/www/html/uploads && \
    mkdir -p /var/www/html/cache

# ========================================
# 9. Copiar código da aplicação
# ========================================
COPY . /var/www/html/

# ========================================
# 10. Definir permissões corretas
# ========================================
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 775 /var/www/html/logs && \
    chmod -R 775 /var/www/html/tmp && \
    chmod -R 775 /var/www/html/uploads && \
    chmod -R 775 /var/www/html/cache

# ========================================
# 11. Verificar instalação
# ========================================
RUN php -v && \
    apache2ctl -v && \
    php -m | grep -E "gd|mysqli|pdo|zip|bcmath"

# ========================================
# 12. Health Check
# ========================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# ========================================
# 13. Configurações de inicialização
# ========================================
EXPOSE 80 443

# Iniciar Apache em foreground
CMD ["apache2-foreground"]
