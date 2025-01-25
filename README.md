# **DashProm con Docker**

Este README explica cómo utilizar el sistema de monitoreo de métricas **DashProm**, que incluye un **agente**, un **cliente**, un **servidor**, y un programa de **prueba de estrés**. Además, se detalla cómo contenerizar el servidor utilizando Docker para facilitar su despliegue. El sistema monitorea métricas en tiempo real, envía alertas por WhatsApp cuando se superan ciertos umbrales, y simula altos consumos de recursos para pruebas.

---

### **Requisitos previos**

- **Twilio API**: Necesitas una cuenta de Twilio con las siguientes credenciales:
  - `ACCOUNT_SID`
  - `AUTH_TOKEN`
  - Números de teléfono configurados para WhatsApp.
- **Docker y Docker Compose**: Instalados en tu sistema.
- **Dependencias del sistema** (para cliente y agente):
  - `free`, `sensors`, `df`, `ip`, y `ps`.

---

### **Estructura del proyecto**

1. **`agente.c`**:
   - Recolecta métricas del sistema como CPU, memoria, disco, procesos activos, temperatura, red y uso de swap.
   - Genera un reporte tabular de las métricas.

2. **`cliente.c`**:
   - Ejecuta el **agente**, recolecta las métricas y las envía al servidor.
   - Permite configurar el intervalo de envío.

3. **`servidor.c`**:
   - Recibe las métricas, verifica umbrales y envía alertas vía WhatsApp utilizando la API de Twilio.
   - Ahora contenerizado con Docker para un despliegue más sencillo.

4. **`prueba_estres.c`**:
   - Simula carga en CPU, memoria y disco para validar el sistema.

---

### **Dockerización del servidor**

#### **1. Dockerfile**
El `Dockerfile` define cómo construir la imagen del servidor. Incluye:
- Uso de una imagen base (`debian:bullseye`).
- Instalación de dependencias (`gcc`, `libcurl`).
- Compilación del servidor (`servidor.c`).
- Exposición del puerto `8080`.

#### **2. docker-compose.yml**
El archivo `docker-compose.yml` gestiona la ejecución del servidor. Incluye:
- Construcción de la imagen desde el `Dockerfile`.
- Mapeo del puerto `8080` del contenedor al host.
- Configuración de variables de entorno sensibles a través de un archivo `.env`.

#### **3. Variables de entorno**
Crea un archivo `.env` (no lo subas al repositorio):

```
TWILIO_ACCOUNT_SID=tu_account_sid
TWILIO_AUTH_TOKEN=tu_auth_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886
TWILIO_RECIPIENT_WHATSAPP_NUMBER=whatsapp:+1234567890
```

Agrega el archivo `.env` a tu `.gitignore` para evitar subirlo a GitHub.

---

### **Cómo ejecutar el proyecto con Docker**

1. **Construir y levantar el servidor**
   En el directorio del proyecto, ejecuta:

   ```bash
   docker-compose up --build
   ```

   Esto:
   - Compila el servidor.
   - Lo expone en el puerto `8080` de tu máquina.

2. **Conectar los clientes al servidor**
   - Asegúrate de usar la dirección IP de tu máquina en la red **bridge** de las máquinas virtuales.
   - Configura el cliente para conectarse a esa IP. Por ejemplo:
     ```c
     inet_pton(AF_INET, "192.168.1.100", &serv_addr.sin_addr);
     ```

---

### **Cómo ejecutar el cliente y prueba de estrés**

1. **Ejecutar el cliente**
   - Desde una máquina virtual conectada al servidor:
     ```bash
     ./cliente <nombre_cliente> <intervalo_actualizacion>
     ```

2. **Ejecutar la prueba de estrés**
   - Desde cualquier máquina para validar:
     ```bash
     ./prueba_estres -m 4000 -t 16 -d 60 -f 2000
     ```

---

### **Alertas y Umbrales**

El servidor envía alertas cuando:
- CPU > 90%
- Memoria > 80%
- Disco > 90%
- Temperatura del CPU > 85°C

Si las métricas superan estos valores, recibirás notificaciones por WhatsApp.

---

### **Dependencias**

1. **Para el servidor (contenarizado)**:
   - Docker y Docker Compose.
   - `libcurl` ya se incluye en la imagen Docker.

2. **Para cliente y agente**:
   - `free`, `sensors`, `df`, `ps`.
