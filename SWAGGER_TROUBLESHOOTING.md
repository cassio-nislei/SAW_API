# 🔌 Troubleshooting - Swagger UI na VPS

## Problema

Swagger UI aparece apenas o título, mas a documentação não carrega.

## Causa

O arquivo `swagger.json` não está sendo servido corretamente quando hospedado na VPS.

---

## ✅ Soluções

### 1️⃣ Verificar se swagger.json existe

```bash
# SSH na VPS
ssh seu_usuario@104.234.173.105

# Verificar arquivo
ls -la /var/www/html/api/swagger.json

# Deve mostrar o arquivo com permissões 644 ou 755
```

### 2️⃣ Verificar permissões

```bash
# Dar permissão de leitura
chmod 644 /var/www/html/api/swagger.json
chmod 755 /var/www/html/api

# Dar permissão ao Apache (se necessário)
chown -R www-data:www-data /var/www/html/api
```

### 3️⃣ Verificar se .htaccess está funcionando

```bash
# Testar acesso direto ao swagger.json
curl http://104.234.173.105:7080/api/swagger.json | head -20

# Deve retornar JSON válido, não HTML de erro
```

### 4️⃣ Verificar Apache config

```bash
# SSH na VPS
ssh seu_usuario@104.234.173.105

# Verificar se mod_rewrite está habilitado
apache2ctl -M | grep rewrite

# Deve mostrar: rewrite_module (shared)

# Se não estiver habilitado:
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### 5️⃣ Testar swagger-json.php (fallback)

```bash
# Testar acesso via PHP
curl http://104.234.173.105:7080/api/swagger-json.php | head -20

# Deve retornar JSON válido
```

### 6️⃣ Verificar Console do Navegador

```javascript
// Abrir DevTools (F12) → Console
// Procurar por erros de CORS ou requisições falhadas

// Se ver erro de CORS, verificar headers:
fetch("http://104.234.173.105:7080/api/swagger.json")
  .then((r) => r.json())
  .then((data) => console.log(data))
  .catch((e) => console.error(e));
```

---

## 🔧 Checklist de Configuração

- [ ] Arquivo `swagger.json` existe em `/var/www/html/api/`
- [ ] Permissões corretas: `644` para arquivo, `755` para diretório
- [ ] `mod_rewrite` habilitado no Apache
- [ ] `.htaccess` presente em `/var/www/html/api/`
- [ ] `swagger-ui.html` presente em `/var/www/html/api/`
- [ ] `swagger-json.php` presente em `/var/www/html/api/`
- [ ] Apache foi reiniciado após mudanças
- [ ] Navegador sem cache (Ctrl+Shift+Del)

---

## 📋 Arquivos Necessários

Certifique-se de ter na VPS:

```
/var/www/html/api/
├── .htaccess              ✅ Configuração Apache
├── swagger.json           ✅ Especificação OpenAPI
├── swagger-ui.html        ✅ Interface web
├── swagger-json.php       ✅ Fallback PHP
└── v1/
    └── index.php          ✅ API endpoints
```

---

## 🐳 Se Usar Docker

### Copiar arquivos para container

```bash
docker-compose exec web cp /var/www/html/api/.htaccess /var/www/html/api/
docker-compose exec web cp /var/www/html/api/swagger-json.php /var/www/html/api/
```

### Reiniciar Apache

```bash
docker-compose exec web apache2ctl graceful
```

### Verificar logs

```bash
docker-compose logs -f web
```

---

## 🌐 URLs para Testar

### URL do Swagger UI

```
http://104.234.173.105:7080/api/swagger-ui.html
```

### URLs para carregar swagger.json

```
# Teste uma destas URLs no navegador:
http://104.234.173.105:7080/api/swagger.json
http://104.234.173.105:7080/api/swagger-json.php
```

Se uma funcionar e retornar JSON, o Swagger UI deve carregar.

---

## 🆘 Se Ainda Não Funcionar

### Opção 1: Usar servidor de desenvolvimento

```bash
# Na VPS, temporariamente servir com Python
cd /var/www/html/api
python3 -m http.server 8000

# Acessar: http://104.234.173.105:8000/swagger-ui.html
```

### Opção 2: Copiar swagger-ui.html para raiz

```bash
# Copiar para raiz do projeto
cp /var/www/html/api/swagger-ui.html /var/www/html/swagger-ui.html

# Acessar: http://104.234.173.105:7080/swagger-ui.html
```

### Opção 3: Usar CDN do Swagger

Criar arquivo simples que usa CDN:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Swagger UI</title>
    <link
      rel="stylesheet"
      type="text/css"
      href="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.1.3/swagger-ui.css"
    />
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.1.3/swagger-ui.js"></script>
    <script>
      const ui = SwaggerUIBundle({
        url: "http://104.234.173.105:7080/api/swagger.json",
        dom_id: "#swagger-ui",
      });
    </script>
  </body>
</html>
```

---

## 📞 Suporte Rápido

| Erro                    | Solução                             |
| ----------------------- | ----------------------------------- |
| **Só título aparece**   | Verificar `.htaccess` e permissões  |
| **CORS error**          | Verificar cabeçalhos em `.htaccess` |
| **404 on swagger.json** | Verificar se arquivo existe         |
| **500 error**           | Verificar logs do Apache            |
| **Conexão recusada**    | Firewall ou porta errada            |

---

## 📝 Próximos Passos

1. Verificar arquivo em SSH
2. Confirmar permissões
3. Testar `curl` no servidor
4. Limpar cache do navegador
5. Testar em abas privadas
6. Verificar console do navegador (F12)

---

**Criado**: 19/11/2025  
**Versão**: 1.0.0  
**Status**: ✅ Pronto para Uso
