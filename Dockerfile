FROM ubuntu:18.04
RUN apt-get update -y \
    && apt-get install -y python3 python3-pip \
    && pip3 install supervisor Flask \
    && mkdir -p /var/log/supervisor /etc/supervisor/conf.d

RUN apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:vbernat/haproxy-2.0 \
    && apt-get -y update && apt-get install -y haproxy

EXPOSE 80 5000
ENV DOMAIN_NAME domain.com

COPY config/supervisord.conf /etc/supervisor
COPY config/haproxy.cfg /etc/haproxy
COPY src /app
WORKDIR /app
RUN pip3 install -r requirements.txt
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
