FROM ubuntu:18.04
MAINTAINER SimJoonYeol "jysim@yujinrobot.com"

RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
RUN make install

EXPOSE 39512

ENTRYPOINT ["/bin/bash"]
CMD ["run_log_aggregator_server.sh"]
