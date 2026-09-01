# Guia Docker - BullsApp

## Pré-requisitos

- Docker instalado (versão 20.10 ou superior)
- Docker Compose instalado (versão 2.0 ou superior)

## Build e Execução

### Opção 1: Usando Docker Compose (Recomendado)

```bash
# Build da imagem e iniciar o container
docker-compose up --build

# Apenas iniciar se já foi buildado
docker-compose up

# Parar o container
docker-compose down
```

A aplicação estará disponível em `http://localhost`

### Opção 2: Usando Docker CLI

```bash
# Build da imagem
docker build -t bullsapp:latest .

# Executar o container
docker run -p 80:80 --name bullsapp bullsapp:latest

# Parar o container
docker stop bullsapp

# Remover o container
docker rm bullsapp
```

## Estrutura do Dockerfile

O Dockerfile utiliza um **build multi-stage** para otimizar o tamanho final da imagem:

### Stage 1: Build
- Usa `google/dart:3.9` como base
- Instala Flutter
- Compila o projeto para web
- Resultado: aplicação web compilada

### Stage 2: Runtime
- Usa `nginx:alpine` como base
- Copia a aplicação compilada
- Configura nginx com suporte a SPA (Single Page Application)
- **Tamanho final reduzido** em comparação a manter a imagem de build

## Configuração do Nginx

O arquivo `nginx.conf` configura:

- **Gzip compression**: Compressão de assets
- **Cache control**: 
  - Assets (JS/CSS/imagens): 1 ano
  - HTML: 10 minutos
  - Service Worker: sem cache
- **Segurança**: Headers de segurança (X-Content-Type-Options, X-Frame-Options, etc)
- **SPA routing**: Redirecionamento para index.html para rotas da aplicação

## Variáveis de Ambiente

Você pode personalizar o build passando variáveis:

```bash
docker build \
  --build-arg FLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/ \
  -t bullsapp:latest .
```

## Health Check

O container possui um health check automático que:
- Verifica a cada 30 segundos
- Timeout de 3 segundos
- Considera o container saudável após 3 verificações bem-sucedidas
- Inicia verificações 5 segundos após o container iniciar

## Limpeza e Manutenção

```bash
# Ver imagens
docker images | grep bullsapp

# Remover imagem
docker rmi bullsapp:latest

# Ver containers em execução
docker ps

# Ver todos os containers
docker ps -a

# Ver logs do container
docker logs -f bullsapp
```

## Otimizações Aplicadas

1. **Multi-stage build**: Reduz o tamanho final da imagem
2. **Alpine nginx**: Imagem base muito menor
3. **.dockerignore**: Evita copiar arquivos desnecessários
4. **Gzip compression**: Reduz tamanho dos assets servidos
5. **Cache control**: Melhora performance do cliente
6. **Health checks**: Monitora saúde do container

## Troubleshooting

### Porta 80 já em uso
```bash
# Usar outra porta
docker run -p 8080:80 bullsapp:latest
# Acesse em http://localhost:8080
```

### Ver logs detalhados
```bash
docker logs -f bullsapp --tail 50
```

### Entrar no container
```bash
docker exec -it bullsapp sh
```

## Recursos

- [Documentação Flutter Web](https://flutter.dev/docs/development/platform-integration/web)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
