FROM ubuntu



LABEL org.opencontainers.image.title="Demo Web Server" \

      org.opencontainers.image.description="Demo with Visual Charts" \

      org.opencontainers.image.authors="@Sec Chu"



COPY . /

RUN apt update && apt install -y nginx

EXPOSE 80/tcp

CMD ["nginx", "-g", "daemon off;"]