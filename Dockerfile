FROM golang:latest

EXPOSE 80

RUN mkdir -p /tmp/git-mirror /root/.ssh

# can't manually prompt the user for host key checking,
# so disable it and hope the user knows their environment
RUN echo "Host *\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null\n" > /root/.ssh/config

RUN git clone https://github.com/fasterthanlime/git-mirror.git /app

WORKDIR /app

RUN go get -d -v .
RUN go build -v .

CMD /app/app --gitlabhost $GIT_HOST --port 80 --path $WEBHOOK_PATH --secret $WEBHOOK_SECRET
