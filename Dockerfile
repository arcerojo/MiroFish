FROM python:3.11

# Instalar Node.js y herramientas necesarias
RUN apt-get update \
  && apt-get install -y --no-install-recommends nodejs npm \
  && rm -rf /var/lib/apt/lists/*

# Copiar uv desde la imagen oficial
COPY --from=ghcr.io/astral-sh/uv:0.9.26 /uv /uvx /bin/

WORKDIR /app

# Copiar archivos de dependencias
COPY package.json package-lock.json ./
COPY frontend/package.json frontend/package-lock.json ./frontend/
COPY backend/pyproject.toml backend/uv.lock ./backend/

# Instalar dependencias
RUN npm ci \
  && npm ci --prefix frontend \
  && cd backend && uv sync --frozen

# Copiar código fuente
COPY . .

EXPOSE 3000 5001

# --- CORRECCIÓN CLAVE ---
# Añadir el entorno virtual al PATH del sistema. 
# Esto asegura que 'npm run dev' encuentre todas las librerías de Python.
ENV PATH="/app/backend/.venv/bin:$PATH"
# ------------------------

# Iniciar aplicación
CMD ["npm", "run", "dev"]
