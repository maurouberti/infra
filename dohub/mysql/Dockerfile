FROM mysql:8.0.27

RUN ln -snf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

CMD ["mysqld", "--innodb_use_native_aio=0", "--default-authentication-plugin=mysql_native_password", "--table_definition_cache=1024"]
