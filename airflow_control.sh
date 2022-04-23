#!/bin/bash

# https://airflow.apache.org/docs/apache-airflow/stable/start/docker.html#docker-compose-yaml


download() {
echo -e "\nRunning download()"
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.2.5/docker-compose.yaml'
}


start() {
echo -e "\nRunning start()"
export AIRFLOW_UID=1000
mkdir -p ./dags ./logs ./plugins
echo -e "AIRFLOW_UID=$(id -u)" > .env
docker-compose -f docker-compose.yaml up
# visit:  https://192.168.178.77:5555/
# visit:  https://192.168.178.77:8080/
  # username: airflow
  # pass airflow
# Docker dags visit:  http://192.168.178.77:8080/home?status=all&search=docker
}


test() {
echo -e "\nRunning test()"
ENDPOINT_URL="http://localhost:8080/"
curl -X GET  \
    --user "airflow:airflow" \
    "${ENDPOINT_URL}/api/v1/pools"
}


clean() {
echo -e "\nRunning clean()"
docker-compose down --remove-orphans --volumes
docker stop $(docker ps -a -q) && docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)
docker network rm $(docker network ls -q)
docker volume rm $(docker volume ls -q)
##rm -rf dags logs  plugins
}


install_providers() {
echo -e "\nRunning install_providers()"
# https://airflow.apache.org/docs/apache-airflow/stable/concepts/operators.html
# https://airflow.apache.org/docs/apache-airflow-providers/packages-ref.html
pip install apache-airflow-providers-docker
}


setup_python() {
echo -e "\nRunning setup_python()"
python3 -m venv venv
. ./venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install jinja2 pyyaml
}


activate_python() {
echo -e "\nRunning activate_python()"
. ./venv/bin/activate
which pip
}


generate_dags() {
echo -e "\nRunning generate_dags()"
. ./venv/bin/activate
python dags/dynamic_dags/generator.py
}

main() {
echo -e "\nRunning main()"
# setup_python
# activate_python
generate_dags
echo -e "\n"
}


main
