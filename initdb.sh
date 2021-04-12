#!/usr/bin/env bash

sleep 30
DEFAULT_DB=$DB_NAME

if [ ! -f /init.lock ]; then

  # wait for database to start...
  for i in {40..0}; do
    if sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -Q 'SELECT 1;' &> /dev/null; then

      echo "$0: SQL Server started $DB_HOST"
      break
    fi
    echo  $DB_HOST
    echo "$0: SQL Server startup in progress..."
    sleep 1
  done

  echo "$0: Initializing database"

  sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -X -i  /home/wso2carbon/wso2is-5.11.0/dbscripts/mssql.sql; 
  sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -X -i  /home/wso2carbon/wso2is-5.11.0/dbscripts/bps/bpel/create/mssql.sql; 
  sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -X -i  /home/wso2carbon/wso2is-5.11.0/dbscripts/identity/mssql.sql; 
  sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -X -i  /home/wso2carbon/wso2is-5.11.0/dbscripts/identity/uma/mssql.sql;
  sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -X -i  /home/wso2carbon/wso2is-5.11.0/dbscripts/metrics/mssql.sql;


  
  for f in /home/wso2carbon/wso2is-5.11.0/dbscripts/identity/stored-procedures/mssql/token-cleanup/*; do
    case "$f" in      
      *.sql)    echo "$0: running $f"; sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -X -i  "$f"; echo ;;
      *)        echo "$0: ignoring $f" ;;
    esac
    echo
  done

  for f in /home/wso2carbon/wso2is-5.11.0/dbscripts/identity/stored-procedures/mssql/sessiondata-cleanup/*; do
    case "$f" in      
      *.sql)    echo "$0: running $f"; sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USERNAME -P $DB_PASSWORD -X -i  "$f"; echo ;;
      *)        echo "$0: ignoring $f" ;;
    esac
    echo
  done
  #END INITIALIZE SQL SERVER WITH SCRIPTS

  echo "$0: SQL Server Database ready"


  touch /init.lock


fi

/home/wso2carbon/docker-entrypoint.sh