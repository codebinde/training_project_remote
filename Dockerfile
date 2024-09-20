FROM docker.io/elixir:latest

ADD . /root/online_mock
RUN mix local.hex --force &&\
    mix local.rebar --force &&\
    git config --global url."https://gitlab-ci-token:CIJOBTOKEN@gitlab.tmecosys.net/".insteadOf "https://gitlab.tmecosys.net/" &&\
    cd /root/online_mock &&\
    mix deps.get &&\
    mix release docker

EXPOSE 4000
EXPOSE 4001
EXPOSE 4002
EXPOSE 4003
EXPOSE 4004
EXPOSE 4005
WORKDIR /root/online_mock

ENTRYPOINT ["_build/dev/rel/docker/bin/docker", "start"]
