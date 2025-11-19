# SAW API - Quick Reference Guide

## 🚀 Quick Start

### API Base URL

```
http://104.234.173.105:7080/api/v1
```

### Access Documentation

- **Interactive Swagger UI:** http://104.234.173.105:7080/api/swagger-ui.html
- **Swagger JSON:** http://104.234.173.105:7080/api/swagger-json.php
- **Postman Collection:** Import `api/SAW_API_Postman.json`

---

## 📊 Key Endpoints

### Health & Status

```
GET /
```

Returns: `{ message: "API funcionando corretamente" }`

### Atendimentos (Attendances)

```
GET    /atendimentos                           # List all
POST   /atendimentos                           # Create new
GET    /atendimentos/{id}                      # Get by ID
GET    /atendimentos/ativos                    # Get active
PUT    /atendimentos/{id}/situacao             # Update status
PUT    /atendimentos/{id}/setor                # Update sector
POST   /atendimentos/{id}/finalizar            # Finalize
```

### Mensagens (Messages)

```
GET    /atendimentos/{id}/mensagens            # List messages
POST   /atendimentos/{id}/mensagens            # Create message
GET    /atendimentos/{id}/mensagens/{mid}      # Get message
PUT    /atendimentos/{id}/mensagens/{mid}      # Update message
DELETE /atendimentos/{id}/mensagens/{mid}      # Delete message
POST   /atendimentos/{id}/mensagens/{mid}/reacao  # Add reaction
```

### Other Resources

```
GET /menus                                     # List menus
GET /parametros                                # List parameters
GET /horarios                                  # List schedules
POST /atendimentos/{id}/anexos                 # Upload attachment
```

---

## 🔧 Quick Examples

### List Attendances with cURL

```bash
curl -i http://104.234.173.105:7080/api/v1/atendimentos
```

### Create Attendance with cURL

```bash
curl -X POST http://104.234.173.105:7080/api/v1/atendimentos \
  -H "Content-Type: application/json" \
  -d '{
    "numero": "123456",
    "cliente": "John Doe",
    "setor": "suporte",
    "prioridade": "alta"
  }'
```

### Get Specific Attendance

```bash
curl http://104.234.173.105:7080/api/v1/atendimentos/1
```

### With Postman

1. Open Postman
2. Import `api/SAW_API_Postman.json`
3. Select any endpoint and click "Send"

---

## 📋 Request/Response Format

### Request Headers Required

```
Content-Type: application/json
Accept: application/json
```

### Response Headers

```
Access-Control-Allow-Origin: *
Content-Type: application/json; charset=utf-8
```

### Standard Response Format

```json
{
  "success": true,
  "data": [
    /* array of results */
  ],
  "message": "Operation successful",
  "pagination": {
    "current": 1,
    "per_page": 20,
    "total": 100
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": "Error message",
  "code": 400
}
```

---

## 🔐 Query Parameters

### Pagination

```
?page=1&perPage=20
```

### Common Filters

```
?page=1                  # Page number
?perPage=50             # Items per page (max 100)
?setor=suporte          # Filter by sector
?situacao=ativo         # Filter by status
```

---

## ✅ Status Codes

| Code | Meaning                            |
| ---- | ---------------------------------- |
| 200  | Success - Request OK               |
| 201  | Created - Resource created         |
| 400  | Bad Request - Invalid data         |
| 404  | Not Found - Resource doesn't exist |
| 500  | Server Error - Check server logs   |

---

## 🐛 Troubleshooting

### Check API Status

```bash
curl -i http://104.234.173.105:7080/api/v1/
```

### Verify CORS Headers

```bash
curl -i http://104.234.173.105:7080/api/v1/menus
# Look for: Access-Control-Allow-Origin: *
```

### Check Swagger Documentation Loads

```bash
curl -i http://104.234.173.105:7080/api/swagger-json.php
# Should return 200 with valid JSON
```

### View Browser Console

1. Open http://104.234.173.105:7080/api/swagger-ui.html
2. Press F12 to open Developer Tools
3. Go to Console tab
4. Look for errors or connection messages

---

## 📱 Example: Creating an Attendance

### Step 1: Prepare Request

```json
{
  "numero": "ATD-001",
  "cliente": "João Silva",
  "setor": "suporte",
  "assunto": "Problema no login",
  "prioridade": "alta",
  "situacao": "aberto"
}
```

### Step 2: Send Request

```bash
curl -X POST \
  http://104.234.173.105:7080/api/v1/atendimentos \
  -H "Content-Type: application/json" \
  -d '{"numero":"ATD-001","cliente":"João Silva","setor":"suporte",...}'
```

### Step 3: Get Response

```json
{
  "success": true,
  "data": {
    "id": 123,
    "numero": "ATD-001",
    "cliente": "João Silva",
    "criado_em": "2025-11-19 23:00:00"
  },
  "message": "Atendimento criado com sucesso"
}
```

---

## 🔗 Important URLs

| Resource         | URL                                               |
| ---------------- | ------------------------------------------------- |
| **API Base**     | http://104.234.173.105:7080/api/v1                |
| **Swagger UI**   | http://104.234.173.105:7080/api/swagger-ui.html   |
| **Swagger JSON** | http://104.234.173.105:7080/api/swagger-json.php  |
| **Test Page**    | http://104.234.173.105:7080/api/test-swagger.html |
| **Health Check** | http://104.234.173.105:7080/api/v1/               |

---

## 💾 File Locations

| File                       | Purpose                   |
| -------------------------- | ------------------------- |
| `api/swagger-ui.html`      | Interactive documentation |
| `api/swagger.json`         | OpenAPI 3.0 specification |
| `api/swagger-json.php`     | JSON endpoint with CORS   |
| `api/SAW_API_Postman.json` | Postman collection        |
| `api/v1/index.php`         | API router                |
| `api/v1/config.php`        | Database configuration    |
| `api/v1/models/`           | Data models               |
| `api/v1/controllers/`      | Business logic            |

---

## 🚀 Deployment Status

✅ **Status:** Production Ready  
✅ **Database:** Connected (104.234.173.105:3306)  
✅ **Endpoints:** 24 operational  
✅ **CORS:** Enabled  
✅ **Documentation:** Available  
✅ **Testing:** Complete

---

## 📞 Support Resources

1. **Documentation:** http://104.234.173.105:7080/api/swagger-ui.html
2. **Postman Collection:** Import `api/SAW_API_Postman.json`
3. **API Specification:** `api/swagger.json` (OpenAPI 3.0.0)
4. **Database:** MySQL at 104.234.173.105:3306
5. **Server Logs:** Check Docker container logs for debugging

---

Last Updated: November 19, 2025  
API Version: 1.0.0  
Database: saw15 (35 tables)
