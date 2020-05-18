import os, signal, subprocess
from flask import Flask, request
from jinja2 import Environment, FileSystemLoader

app = Flask(__name__)

@app.route('/', methods = ['GET', 'POST', 'PATCH', 'PUT', 'DELETE'])
def api_root():
    if request.method == 'PUT':
        endpoints = request.json
        env = Environment(loader=FileSystemLoader ('templates'), trim_blocks=True)
        template = env.get_template('haproxy.jinja2.cfg')
        rendered_cfg = template.render(endpoints = endpoints, domain_name = os.getenv('DOMAIN_NAME'))
        ha_cfg = open('/etc/haproxy/haproxy.cfg','w')
        ha_cfg.write(rendered_cfg)
        ha_cfg.close
        # Send SIGUSR2 signal to reload configuration
        os.kill(int(subprocess.run(["cat", "/tmp/haproxy.pid"], stdout=subprocess.PIPE).stdout), signal.SIGUSR2)
        return "Configuration Reloaded"
        

if __name__ == "__main__":
    app.run(host = "0.0.0.0")
