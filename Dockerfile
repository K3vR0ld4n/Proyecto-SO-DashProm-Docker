FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    gcc \
    make \
    curl \
    libcurl4-openssl-dev

WORKDIR /app

COPY servidor.c /app/servidor.c

RUN gcc -o servidor servidor.c -lcurl

EXPOSE 8080

CMD ["./servidor"]
