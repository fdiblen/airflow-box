import os.path
from datetime import datetime, timedelta

from docker.types import Mount

from airflow import DAG
from airflow.decorators import task, dag
from airflow.operators.bash_operator import BashOperator
from airflow.operators.docker_operator import DockerOperator
from airflow.operators.python_operator import BranchPythonOperator
from airflow.operators.dummy_operator import DummyOperator


default_args = {
    'owner'                 : 'airflow',
    'description'           : 'Use of the DockerOperator',
    'depend_on_past'        : False,
    'start_date'            : datetime(2022,4, 22),
    'email_on_failure'      : False,
    'email_on_retry'        : False,
    'retries'               : 0,
    'retry_delay'           : timedelta(minutes=1)
}

def checkIfRepoAlreadyCloned():
    if os.path.exists('/home/airflow/test/.git'):
        return 'dummy'
    return 'git_clone'


with DAG('docker_dag_simple', default_args=default_args, schedule_interval="5 * * * *", catchup=False) as dag:

    @task()
    def dummy():
        pass

    task_check_repo = BranchPythonOperator(
        task_id='is_repo_exists',
        python_callable=checkIfRepoAlreadyCloned
    )

    task_git_clone = BashOperator(
        task_id='git_clone',
        bash_command='git clone https://github.com/fdiblen/test-airflow.git /home/airflow/test-airflow'
    )

    task_git_pull = BashOperator(
        task_id='git_pull',
        bash_command='cd /home/airflow/test-airflow && git pull',
        trigger_rule='one_success'
    )

    # https://airflow.apache.org/docs/apache-airflow/1.10.13/_api/airflow/operators/docker_operator/index.html
    # https://github.com/apache/airflow/tree/main/airflow/providers/docker/example_dags
    task_docker = DockerOperator(
        task_id='docker_command',
        image='alpine:latest',
        api_version='auto',
        auto_remove=True,
        environment={
            'MYHOME': "Universe",
        },
        command='ls /data ',
        # docker_url='unix://var/run/docker.sock',
        docker_url='tcp://docker-proxy:2375',
        network_mode='bridge',
        xcom_all=True,
        # retrieve_output=True,
        # retrieve_output_path='/data/log.txt',
        mounts=[
            Mount(source="/home/fdiblen/airflow", target="/data", type="bind"),
        ],
    )

    # task_check_repo >> task_git_clone
    # # task_check_repo >> task_dummy >> task_git_pull
    # task_git_clone >> task_git_pull
    # task_git_pull >> task_docker

    dummy() >> task_docker
