# 🐳 Docker Setup - SAW API

## 📋 Mudanças Realizadas

### docker-compose.yml

- ✅ Atualizado para versão `3.8`
- ✅ Adicionado serviço MySQL 8.0
- ✅ Configuração correta de `sql_mode` (resolve erros de GROUP BY)
- ✅ Volumes persistentes para banco de dados
- ✅ Health check para MySQL
- ✅ Variáveis de ambiente centralizadas
- ✅ Network bridge em vez de externa

### Dockerfile

- ✅ Extensões PHP otimizadas
- ✅ mod_rewrite habilitado
- ✅ Configurações de upload e performance
- ✅ Permissões corretas

### mysql-init.sql (novo)

- ✅ Inicialização automática do banco
- ✅ Configuração de `sql_mode` sem GROUP BY completo
- ✅ Criação de usuário com permissões

---

## 🚀 Como Usar

### 1. Iniciar Containers

```bash
docker-compose up -d
```

### 2. Verificar Status

```bash
docker-compose ps
```

### 3. Acessar Aplicação

```
http://localhost:7080
```

### 4. Acessar MySQL

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
