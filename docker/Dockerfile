FROM swaggerapi/swagger-ui:latest

RUN apk update && apk add --no-cache bash jq

COPY docker/entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

COPY gen/openapi /usr/share/nginx/html/openAPI

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
