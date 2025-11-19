# Configuração do Servidor - SAW API v1

## 🔧 Habilitando mod_rewrite (Apache)

O mod_rewrite é necessário para que as URLs da API funcionem sem o `index.php` visível.

### Windows (XAMPP)

#### 1. Verificar se mod_rewrite está habilitado

Abra `php/apache2/conf/httpd.conf` e procure por:

```apache
#LoadModule rewrite_module modules/mod_rewrite.so
```

Se estiver comentado (começar com `#`), descomente removendo o `#`:

```apache
LoadModule rewrite_module modules/mod_rewrite.so
```

#### 2. Verificar AllowOverride

No mesmo arquivo, procure por `<Directory>` para sua pasta raiz:

```apache
<Directory "c:/xampp/htdocs">
    ...
    AllowOverride All
    ...
</Directory>
```

Certifique-se que tem `AllowOverride All` (ou pelo menos `AllowOverride FileInfo`).

#### 3. Reiniciar Apache

- Parar Apache no XAMPP Control Panel
- Iniciar Apache novamente

### Linux (Apache)

```bash
# Habilitar mod_rewrite
sudo a2enmod rewrite

# Reiniciar Apache
sudo systemctl restart apache2
```

### Verificar se está funcionando

Execute no terminal:

```bash
# URL com reescrita (deve funcionar)
curl http://localhost/SAW-main/api/v1/atendimentos

# URL sem reescrita (deve redirecionar)
curl http://localhost/SAW-main/api/v1/index.php/atendimentos
```

---

## 🔍 Testando a Configuração

### 1. Criar arquivo de teste

Crie `api/v1/test-rewrite.php`:

```php
<?php
echo "✅ mod_rewrite está funcionando!";
echo "\n\nCaminhos:";
echo "\nPATH_INFO: " . $_SERVER['PATH_INFO'] ?? 'vazio';
echo "\nREQUEST_URI: " . $_SERVER['REQUEST_URI'] ?? 'vazio';
?>
```

### 2. Testar

```bash
curl http://localhost/SAW-main/api/v1/test-rewrite.php
```

Se retornar "✅ mod_rewrite está funcionando!", tudo está OK.

---

## 🐛 Troubleshooting

### Erro 404 ao acessar API

**Problema**: Apache não encontra os endpoints

**Soluções**:

1. Verificar se mod_rewrite está habilitado

   ```bash
   apache2ctl -M | grep rewrite
   ```

2. Verificar permissões da pasta

   ```bash
   chmod -R 755 /SAW-main/api/v1
   ```

3. Verificar se .htaccess existe

   ```bash
   ls -la /SAW-main/api/v1/.htaccess
   ```

4. Testar URL sem reescrita
   ```bash
   curl http://localhost/SAW-main/api/v1/index.php/atendimentos
   ```

### Erro 500 após habilitar mod_rewrite

**Problema**: Erro de configuração

**Soluções**:

1. Verificar logs do Apache

   ```bash
   tail -f /var/log/apache2/error.log
   ```

2. Validar sintaxe do .htaccess

   ```bash
   # Remover e recriar
   rm /SAW-main/api/v1/.htaccess
   # Recriar com conteúdo correto
   ```

3. Reiniciar Apache
   ```bash
   sudo systemctl restart apache2
   ```

### Ainda não funciona?

Teste a API sem reescrita:

```bash
# Use index.php explicitamente
curl http://localhost/SAW-main/api/v1/index.php?_route=/atendimentos

# Ou configure a API para usar query string
# Editar Router.php para aceitar ?route=
```

---

## 📋 Checklist de Configuração

- [ ] mod_rewrite habilitado em Apache
- [ ] AllowOverride configurado como "All"
- [ ] .htaccess existe em api/v1/
- [ ] Permissões de pasta corretas (755)
- [ ] Apache reiniciado após alterações
- [ ] PHP 7.0+ instalado
- [ ] MySQL 5.7+ rodando
- [ ] Credenciais em api/v1/config.php corretas
- [ ] Pasta api/v1/logs criada e com permissão de escrita

---

## ✅ Verificação Final

Se tudo está configurado:

```bash
# 1. Testar saúde da API
curl http://localhost/SAW-main/api/v1/

# Deve retornar JSON com status success
```

Se retornar:

```json
{
  "status": "success",
  "message": "API funcionando corretamente",
  "data": {
    "api": "SAW API",
    "version": "1.0",
    "status": "running"
  }
}
```

🎉 **API pronta para usar!**

---

## 📌 Notas Importantes

- O arquivo `.htaccess` já foi criado em `api/v1/`
- Contém regras corretas para reescrever URLs
- Não edite sem necessidade
- Se editar, certifique-se de validar sintaxe

---

## 🔗 Referências

- [Apache mod_rewrite Documentation](https://httpd.apache.org/docs/current/mod/mod_rewrite.html)
- [XAMPP Documentation](https://www.apachefriends.org/index.html)
- [PHP URL Rewriting](https://www.php.net/manual/en/language.variables.superglobals.php)

---

**Data:** 19/11/2025  
**Status:** ✅ Guia Completo
