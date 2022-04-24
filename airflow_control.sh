#!/usr/bin/env bash

# https://airflow.apache.org/docs/apache-airflow/stable/start/docker.html#docker-compose-yaml

download() {
  echo -e "\nRunning download()"
  curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.2.5/docker-compose.yaml'
}

prepare() {
  echo -e "\nRunning prepare()"
  docker-compose build
  docker-compose pull
}

update_compose() {
  echo -e "\nRunning update_compose()"
  sudo cp /usr/bin/docker-compose /usr/bin/docker-compose_old
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-x86_64" -o /usr/bin/docker-compose
  sudo chmod +x /usr/bin/docker-compose
}

start() {
  echo -e "\nRunning start()"
  export AIRFLOW_UID=1000
  prepare
  mkdir -p ./dags ./logs ./plugins
  echo -e "AIRFLOW_UID=$(id -u)" > .env
  docker-compose -f docker-compose.yaml up -d
  ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
  ip6=$(/sbin/ip -o -6 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
  echo "
  # Flower UI  : http://${ip4}:5555
  # Airflow UI : http://${ip4}:8080/home
    # username : airflow
    # password : airflow
  # Docker dags: http://${ip4}:8080/home?search=docker
  "
}

stop() {
  echo -e "\nRunning stop()"
  docker-compose down --remove-orphans --volumes
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
  docker-compose down --remove-orphans --volumes --rmi all
  docker stop $(docker ps -a -q) && docker rm -f $(docker ps -a -q)
  docker rmi -f $(docker images -q)
  docker network prune --force
  docker volume prune --force
  rm -rf logs plugins venv
  rm -rf dags/__pycache__ dags/dynamic_dags/__pycache__
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

install_airflow_providers() {
  echo -e "\nRunning install_airflow_providers()"
  # https://airflow.apache.org/docs/apache-airflow/stable/concepts/operators.html
  # https://airflow.apache.org/docs/apache-airflow-providers/packages-ref.html
  pip install apache-airflow-providers-docker
}

install_pip_package() {
  echo -e "\nRunning install_pip_package()"
  # echo "\$@:" "$@"
  # echo "\${extra_pip_packages}:" "${extra_pip_packages}"
  echo "Installing pip packages:" "${extra_pip_packages}"
  . ./venv/bin/activate
  pip install "${extra_pip_packages}"
}

generate_dags() {
  echo -e "\nRunning generate_dags()"
  setup_python
  . ./venv/bin/activate
  python dags/dynamic_dags/generator.py
}

get_shell() {
  echo -e "\nRunning get_shell()"
  docker run --rm -ti --name airflow_tmp \
    --entrypoint bash airflow_airflow-worker:latest
}

help() {
  printf "\nUsage:\n"
  printf "$0
    [--clean|-c]
    [--download|-d]
    [--generate|-g]
    [[--pip|-p] '<package1><package2>']
    [--setuppy|--py]
    [--shell]
    [--start]
    [--stop]
    [--test|-t]
    [--verbose|-v]\n"
  exit 1
}

main() {
  if [ $# -eq 0 ]; then
      help
  fi

  echo -e "\nAirflow control script\n"

  # global variables
  export AIRFLOW_UID=1000

  # get cli arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --clean|-c)
        export clean_option=1
        clean
        ;;
      --download|-d)
        export download_option=1
        download
        ;;
      --generate|-g)
        export generate_option=1
        generate_dags
        ;;
      --pip|-p)
        export pip_option=1
        export extra_pip_packages="${2}"
        install_pip_package ${2}
        shift
        ;;
      --shell|--sh)
        export shell_option=1
        get_shell
        ;;
      --setuppy|--py)
        export py_option=1
        setup_python
        ;;
      --start)
        export start_option=1
        start
        ;;
      --stop)
        export stop_option=1
        stop
        ;;
      --test|-t)
        export test_option=1
        test
        ;;
      --verbose|-v)
        export verbose_option=1
        ;;
      *)
        printf "Invalid parameter: $1\n"
        help
    esac
    shift
  done

  # show variables in verbose mode
  if [ "$verbose_option" = "1" ];
  then
    echo
    echo "SCRIPT VARIABLES"
    echo "  clean_option   : ${clean_option}"
    echo "  download_option: ${download_option}"
    echo "  generate_option: ${generate_option}"
    echo "  pip_option     : ${pip_option}"
    echo "  py_option      : ${py_option}"
    echo "  shell_option   : ${shell_option}"
    echo "  start_option   : ${start_option}"
    echo "  stop_option    : ${stop_option}"
    echo "  test_option    : ${test_option}"
    echo "  verbose_option : ${verbose_option}"
    echo
  fi
}

main "$@"
