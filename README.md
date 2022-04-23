# Airflow-box

Apache Airflow Experiments

## Instructions

Initial Setup

```shell
chmod +x airflow_control.sh
./airflow_control.sh --download
./airflow_control.sh --start
```

Generating dynamic DAGS

```shell
./airflow_control.sh --setuppy
./airflow_control.sh --generate
```

Clean up

```shell
./airflow_control.sh --clean
```

## Dashboard

Flower UI  : <http://192.168.178.77:5555>

Airflow UI : <http://192.168.178.77:8080/home>

username : airflow
password : airflow

Docker dags: <http://192.168.178.77:8080/home?search=docker>
