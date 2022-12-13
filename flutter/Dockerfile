FROM docker.io/cirrusci/flutter:latest AS build-env
COPY . /app/
WORKDIR /app/
RUN flutter build web

FROM docker.io/nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html