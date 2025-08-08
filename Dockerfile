# ----------------------------
# Dockerfile para n8n Enterprise Hack
# ----------------------------
FROM node:20-alpine

# Aumenta heap para até 8 GB
ENV NODE_OPTIONS="--max-old-space-size=8192"

# Instala utilitários e cliente PostgreSQL
RUN apk add --no-cache bash git python3 make g++ postgresql-client

# Variáveis de ambiente para build e hack de licença
ENV DOCKER_BUILD=true \
    NODE_PATH=/usr/src/app/node_modules \
    N8N_SKIP_LICENSE_CHECK=true

WORKDIR /usr/src/app

# Copy package files first for better layer caching
COPY package*.json pnpm-lock.yaml* ./
COPY packages/*/package*.json ./packages/*/

# Install pnpm and dependencies
RUN npm install -g pnpm \
 && pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN pnpm run build && npx update-browserslist-db@latest

# Ajusta script binário (CRLF → LF + permissão)
RUN sed -i 's/\r$//' packages/cli/bin/n8n \
 && chmod +x packages/cli/bin/n8n

# Link global para comando n8n
RUN ln -s /usr/src/app/packages/cli/bin/n8n /usr/local/bin/n8n

# Porta padrão do n8n
EXPOSE 5678

# Inicia o n8n com hack de licença
CMD ["n8n", "start"]
