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
        renderedCfg = template.render(endpoints = endpoints, domainName = os.getenv('DOMAIN_NAME'))
        haCfg = open('/etc/haproxy/haproxy.cfg','w')
        haCfg.write(renderedCfg)
        haCfg.close
        os.kill(int(subprocess.run(["pidof", "-s", "haproxy"], stdout=subprocess.PIPE).stdout),signal.SIGHUP)

        return "Configuration Reloaded"
        

if __name__ == "__main__":
    app.run(host = "0.0.0.0")
