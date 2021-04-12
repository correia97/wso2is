FROM wso2/wso2is:5.11.0
USER root
WORKDIR /home/wso2carbon

RUN apt-get update && \
    apt-get install -y gnupg2 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
    apt-get update && \
    ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive apt-get install -y mssql-tools  && \
    ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive apt-get install -y unixodbc-dev && \
    ls /opt/mssql-tools/bin/sqlcmd* && \
    ln -sfn /opt/mssql-tools/bin/sqlcmd /usr/bin/sqlcmd && \
    rm -rf /var/lib/apt/lists/*

COPY *.jar wso2is-5.11.0/repository/components/lib/
COPY deployment.toml  wso2is-5.11.0/repository/conf/
#COPY user-mgt.xml ./wso2is-5.11.0/repository/conf/user-mgt.xml

ENV DB_TYPE=""
ENV DB_HOST=""
ENV DB_NAME=""
ENV DB_USERNAME=""
ENV DB_PASSWORD=""
ENV DB_PORT=""
ENV DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
ENV USER_NAME="admin"
ENV USER_PASSWORD="admin"

COPY initdb.sh ./

ENTRYPOINT [ "/home/wso2carbon/initdb.sh" ]