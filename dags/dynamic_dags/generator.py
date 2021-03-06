from jinja2 import Environment, FileSystemLoader
import yaml
import os


file_dir = os.path.dirname(os.path.abspath(__file__))
env = Environment(loader=FileSystemLoader(file_dir))
template = env.get_template('docker_dynamic_dag_template.jinja2')


for file_name in os.listdir(file_dir):
    if file_name.endswith(".yaml"):
        with open(f"{file_dir}/{file_name}", "r") as config_file:
            config = yaml.safe_load(config_file)
            with open(f"dags/generated_docker_dag_{config['dag_id']}.py", "w") as dag_file:
                dag_file.write(template.render(config))

