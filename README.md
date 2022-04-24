# Airflow-box

Example repository to show how to use Apache Airflow with DockerOperator.

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

## Dashboard URLs

Flower UI  : <http://SERVER_IP:5555>

Airflow UI : <http://SERVER_IP:8080/home> (username : airflow password : airflow)

Docker dags: <http://SERVER_IP:8080/home?search=docker>
