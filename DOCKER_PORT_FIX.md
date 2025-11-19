# 🐳 Docker Compose - Resolução de Conflitos

## ❌ Erro Recebido

```
ERROR: for saw-api-db Cannot start service db:
Bind for 0.0.0.0:3306 failed: port is already allocated
```

## ✅ Causa

Você já tem um MySQL rodando localmente na **porta 3306**.

## 🔧 Solução Implementada

A porta do Docker MySQL foi **alterada de 3306 para 3307**.

### Mudança em `docker-compose.yml`:

```yaml
# ❌ ANTES:
ports:
  - "3306:3306"

# ✅ DEPOIS:
ports:
  - "3307:3306"
```

**Explicação:**

- `3307` = porta no **host** (sua máquina)
- `3306` = porta dentro do **container** (MySQL padrão)
- O container usa 3306 internamente (normal)
- Mas o host usa 3307 (evita conflito com MySQL local)

---

## 🚀 Próximos Passos

### Opção 1: Windows

```bash
# Duplo clique em:
restart-docker.bat

# Ou execute manualmente:
docker-compose down
docker-compose up -d
```

### Opção 2: Linux/Mac

```bash
# Dar permissão
chmod +x restart-docker.sh

# Executar
./restart-docker.sh

# Ou manualmente:
docker-compose down
docker-compose up -d
```

### Opção 3: Manual

```bash
cd C:\seu\projeto\SAW-main

# Parar containers antigos
docker-compose down

# Iniciar novos
docker-compose up -d

# Verificar status
docker-compose ps
```

---

## ✅ Verificação

Após iniciar:

```bash
# Verificar containers
docker-compose ps

# Deve mostrar:
# saw-api-web    running  port 7080
# saw-api-db     running  port 3307
```

### Testar conexão MySQL (3307):

```bash
mysql -h 127.0.0.1 -P 3307 -u saw_user -p

# Senha: Ncm@647534
```

### Testar acesso web:

```
http://localhost:7080
```

---

## 🔗 Mapeamento de Portas

| Serviço        | Host | Container | URL                     |
| -------------- | ---- | --------- | ----------------------- |
| **PHP/Apache** | 7080 | 80        | `http://localhost:7080` |
| **MySQL**      | 3307 | 3306      | `localhost:3307`        |

---

## 💡 Se Ainda Der Erro

### Erro: Porta 7080 também em uso

Altere em `docker-compose.yml`:

```yaml
# Trocar por:
ports:
  - "8080:80" # Usa 8080 em vez de 7080
```

### Erro: Container não inicia

```bash
# Ver logs
docker-compose logs db

# Remover volume antigo
docker-compose down -v

# Reiniciar
docker-compose up -d
```

### Erro: MySQL não conecta do PHP

Certifique-se que `DB_HOST: db` em `docker-compose.yml` (já está correto).

---

## 📝 Arquivo Atualizado

✅ `docker-compose.yml` - Porta MySQL alterada para 3307

## 📦 Scripts Criados

✅ `restart-docker.bat` - Para Windows  
✅ `restart-docker.sh` - Para Linux/Mac

---

## 🎯 Resumo

| Ação        | Comando                      |
| ----------- | ---------------------------- |
| **Parar**   | `docker-compose down`        |
| **Iniciar** | `docker-compose up -d`       |
| **Status**  | `docker-compose ps`          |
| **Logs**    | `docker-compose logs -f web` |
| **Limpar**  | `docker-compose down -v`     |

---

**Status**: ✅ Pronto para usar  
**Criado**: 19/11/2025  
**Versão**: 1.0.0
