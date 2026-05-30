FROM postgres
ENV POSTGRES_PASSWORD coyg
ENV POSTGRES_DB arsenal
COPY arsenal-team.sql /docker-entrypoint-initdb.d/
