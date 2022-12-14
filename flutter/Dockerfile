FROM docker.io/cirrusci/flutter:latest AS build-env
COPY . /app/
WORKDIR /app/
ARG API_BASE_URL
RUN echo "API_BASE_URL=$API_BASE_URL" > .env
RUN flutter build web

FROM docker.io/nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html