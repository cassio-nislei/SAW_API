# 🐳 Configuração Docker - SAW Application

## 📋 O que foi melhorado?

### ✅ Problemas Resolvidos

1. **Tracking Prevention blocked storage** - ❌ RESOLVIDO
   - Adicionados headers CORS corretos
   - Cookie SameSite configurado para `None` com `Secure`
   - Headers Access-Control-Allow-Credentials habilitados

2. **Plugins jQuery não carregando** - ❌ RESOLVIDO
   - Adicionado módulo `mod_deflate` para compressão
   - Headers Cache-Control configurados corretamente
   - CORS preflight (OPTIONS) suportado
   - Tipos MIME corretos para todos os arquivos

3. **Erro "Cannot read properties of null"** - ❌ RESOLVIDO
   - CORS headers permitindo requisições de qualquer origem
   - Headers Access-Control para POST, PUT, DELETE
   - Compressão gzip habilitada para JSON responses

### 🔧 Configurações Adicionadas

#### Arquivo: `.htaccess`

- ✅ CORS Headers completos
- ✅ Security Headers (HSTS, X-Frame-Options, CSP)
- ✅ Compressão Gzip automática
- ✅ Cache Headers para assets (1 ano)
- ✅ Preflight CORS (OPTIONS)
- ✅ Proteção contra access directory listing
- ✅ Rewrite rules para URLs amigáveis

#### Arquivo: `Dockerfile`

- ✅ Módulos Apache: rewrite, headers, expires, deflate, ssl, proxy
- ✅ Extensões PHP adicionais: zip, bcmath
- ✅ Configuração VirtualHost com suporte HTTPS
- ✅ Health check integrado
- ✅ Permissões de pasta otimizadas
- ✅ Diretórios de logs separados

#### Arquivo: `apache-config.conf`

- ✅ Compressão deflate para todos os tipos
- ✅ Cache busting for assets
- ✅ Security headers HSTS, X-Content-Type-Options, etc
- ✅ Timeouts configurados
- ✅ Remove server headers para segurança

#### Arquivo: `docker-compose.yml`

- ✅ Versão 3.9 com melhorias
- ✅ Volumes para logs (Apache & PHP)
- ✅ Variáveis de ambiente expandidas
- ✅ Health check
- ✅ Deploy resources (CPU/Memory limits)
- ✅ Logging automático
- ✅ Network isolada

---

## 🚀 Como Gerar a Nova Imagem

### Opção 1: PowerShell (Windows)

```powershell
# Navegar para pasta SAWWeb
cd C:\Users\nislei\Downloads\SAW-main\SAWWeb

# Build e iniciar
powershell -ExecutionPolicy Bypass -File docker-manage.ps1 -action build
powershell -ExecutionPolicy Bypass -File docker-manage.ps1 -action start

# Ver logs
powershell -ExecutionPolicy Bypass -File docker-manage.ps1 -action logs
```

### Opção 2: Command Prompt (Windows)

```cmd
# Navegar para pasta
cd C:\Users\nislei\Downloads\SAW-main\SAWWeb

# Copiar .env
copy .env.example .env

# Build
docker-compose build --no-cache

# Iniciar
docker-compose up -d

# Ver logs
docker-compose logs -f
```

### Opção 3: Bash (Linux/Mac)

```bash
# Navegar para pasta
cd SAW-main/SAWWeb

# Dar permissão
chmod +x docker-manage.sh

# Build e iniciar
./docker-manage.sh build
./docker-manage.sh start

# Ver logs
./docker-manage.sh logs
```

---

## 🔍 Verificar Instalação

### Após iniciar o container:

```bash
# Verificar se está rodando
docker ps | grep saw-api-web

# Acessar a aplicação
http://localhost:7080

# Ver status de saúde
docker inspect --format='{{.State.Health.Status}}' saw-api-web

# Ver logs completos
docker-compose logs -f --tail=100
```

---

## 📝 Configurar Banco de Dados

### Arquivo: `.env`

```env
# Copiar de .env.example e editar:
DB_HOST=104.234.173.105
DB_USER=root
DB_PASS=Ncm@647534
DB_NAME=saw_quality
DB_PORT=3306
```

### Testar conexão:

```php
<?php
// test-db-docker.php
$conn = new mysqli(
    getenv('DB_HOST'),
    getenv('DB_USER'),
    getenv('DB_PASS'),
    getenv('DB_NAME')
);

if ($conn->connect_error) {
    die('Erro: ' . $conn->connect_error);
}

echo "✅ Conexão com banco OK!";
?>
```

---

## 🔐 Segurança

As seguintes proteções foram adicionadas:

| Header                             | Valor            | Propósito              |
| ---------------------------------- | ---------------- | ---------------------- |
| `Strict-Transport-Security`        | max-age=31536000 | Forçar HTTPS           |
| `X-Content-Type-Options`           | nosniff          | Prevenir sniffing MIME |
| `X-Frame-Options`                  | SAMEORIGIN       | Prevenir clickjacking  |
| `X-XSS-Protection`                 | 1; mode=block    | Proteção XSS           |
| `Access-Control-Allow-Origin`      | \*               | CORS habilitado        |
| `Access-Control-Allow-Credentials` | true             | Cookies em CORS        |

---

## 📊 Performance

### Otimizações Incluídas:

- ✅ **Compressão Gzip** para CSS, JS, JSON
- ✅ **Cache Headers** (1 ano para assets)
- ✅ **Deflate Compression** fallback
- ✅ **Health Check** automático
- ✅ **Memory Limit** 256MB
- ✅ **Upload Limit** 50MB
- ✅ **Timeout** 300 segundos

---

## 🆘 Troubleshooting

### Erro: "Cannot connect to Docker daemon"

```bash
# Verificar se Docker está rodando
docker --version

# No Windows, iniciar Docker Desktop
# Ou executar: net start docker
```

### Erro: "Port 7080 already in use"

```bash
# Encontrar processo usando porta
lsof -i :7080

# Ou no Windows:
netstat -ano | findstr :7080

# Mudar porta no docker-compose.yml:
# De: 7080:80
# Para: 8080:80
```

### Storage Access Blocked (JavaScript)

- ✅ Headers CORS já configurados
- ✅ SameSite=None; Secure adicionados
- ✅ Reloade o navegador com cache limpo

```bash
# Limpar cache Chrome:
# Ctrl+Shift+Delete (Windows)
# Cmd+Shift+Delete (Mac)
```

### MySQL Connection Failed

```bash
# Verificar variáveis de ambiente
docker-compose ps
docker-compose logs | grep -i "mysql\|database"

# Testar conexão do container
docker exec saw-api-web php -r "
  \$conn = new mysqli('104.234.173.105', 'root', 'Ncm@647534', 'saw_quality');
  echo \$conn->connect_error ?? 'OK';
"
```

---

## 📦 Arquivos Modificados

| Arquivo              | Status        |
| -------------------- | ------------- |
| `.htaccess`          | ✅ Criado     |
| `Dockerfile`         | ✅ Atualizado |
| `docker-compose.yml` | ✅ Atualizado |
| `apache-config.conf` | ✅ Criado     |
| `.env.example`       | ✅ Criado     |
| `docker-manage.ps1`  | ✅ Criado     |
| `docker-manage.sh`   | ✅ Criado     |

---

## ✨ Próximos Passos

1. **Gerar a nova imagem:**

   ```bash
   docker-compose build --no-cache
   ```

2. **Iniciar o container:**

   ```bash
   docker-compose up -d
   ```

3. **Testar no navegador:**
   - Abrir: `http://localhost:7080`
   - Acessar: Conversas > WebChat
   - Testar: Envio de mensagens privadas

4. **Verificar logs:**
   ```bash
   docker-compose logs -f
   ```

---

## 📞 Suporte

Para problemas relacionados:

1. Verificar logs: `docker-compose logs`
2. Reiniciar container: `docker-compose restart`
3. Limpar tudo: `docker-compose down -v`
4. Reconstruir: `docker-compose build --no-cache`

---

**Data de Atualização:** Fevereiro 2026  
**Versão Docker:** 3.9  
**PHP:** 8.2-apache  
**Apache:** 2.4.x

```bash
docker-compose exec db mysql -u saw_user -p saw15
# Senha: Ncm@647534
```

### 5. Ver Logs

```bash
# Logs do PHP/Apache
docker-compose logs -f web

# Logs do MySQL
docker-compose logs -f db
```

---

## 🔧 Configurações Principais

### MySQL

- **Host**: `db` (dentro da rede Docker)
- **Usuário**: `saw_user`
- **Senha**: `Ncm@647534`
- **Database**: `saw15`
- **Porta Interna**: 3306
- **Porta Externa**: 3306

### PHP/Apache

- **Porta**: 7080 (mapeado de 80)
- **Document Root**: `/var/www/html`
- **Volumes**: Código-fonte sincronizado em tempo real

### sql_mode

```sql
STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
```

✅ **Resolve**: Erros de GROUP BY não será tão rigoroso

---

## 📊 Variáveis de Ambiente

| Variável            | Valor      |
| ------------------- | ---------- |
| DB_HOST             | db         |
| DB_USER             | saw_user   |
| DB_PASS             | Ncm@647534 |
| DB_NAME             | saw15      |
| MYSQL_ROOT_PASSWORD | Ncm@647534 |

---

## 🛠️ Comandos Úteis

### Parar tudo

```bash
docker-compose down
```

### Parar e remover volumes

```bash
docker-compose down -v
```

### Rebuildar imagens

```bash
docker-compose up -d --build
```

### Executar comando no container

```bash
docker-compose exec web php -v
docker-compose exec db mysql --version
```

### Ver variáveis MySQL

```bash
docker-compose exec db mysql -u saw_user -p saw15 -e "SELECT @@sql_mode;"
```

---

## ✅ Verificação

Após iniciar, verifique:

1. **PHP está rodando**: `http://localhost:7080`
2. **MySQL está respondendo**:
   ```bash
   docker-compose exec db mysqladmin -u saw_user -p ping
   ```
3. **Banco foi criado**:
   ```bash
   docker-compose exec db mysql -u saw_user -p saw15 -e "SHOW TABLES;"
   ```
4. **sql_mode está correto**:
   ```bash
   docker-compose exec db mysql -u saw_user -p saw15 -e "SELECT @@sql_mode;"
   ```

---

## 🐛 Troubleshooting

### Erro: "Connection refused"

- Aguarde 30s para MySQL iniciar
- Verifique: `docker-compose ps`

### Erro: "sql_mode" ainda ativo

- MySQL pode estar em cache
- Reinicie: `docker-compose restart db`

### Permissões negadas em /var/www/html

- O volume está mapeado, você pode editar localmente

### MySQL não inicia

- Verifique espaço em disco
- Limpe volumes: `docker-compose down -v`

---

## 📝 Próximas Etapas

1. ✅ Iniciar containers: `docker-compose up -d`
2. ✅ Importar dados existentes se houver
3. ✅ Testar aplicação
4. ✅ Verificar erros em logs
5. ✅ Fazer backup do banco: `docker-compose exec db mysqldump -u saw_user -p saw15 > backup.sql`

---

## 🔐 Segurança em Produção

**Para produção, mude:**

- ✋ Senhas (em `docker-compose.yml` e `mysql-init.sql`)
- ✋ Valores de `sql_mode` conforme necessário
- ✋ Use volumes com backup automático
- ✋ Configure reverse proxy (nginx, traefik)
- ✋ Use HTTPS

---

**Criado**: 19/11/2025  
**Status**: ✅ Pronto para Uso  
**Versão**: 1.0.0
