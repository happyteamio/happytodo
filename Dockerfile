FROM elixir:1.4 as builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    && export LANG=en_US.UTF-8 \
    && echo $LANG UTF-8 > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=$LANG \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV MIX_ENV=prod

# Install Hex+Rebar
 RUN mix local.hex --force && \
     mix local.rebar --force

WORKDIR /opt/happy_todo

RUN mkdir config
COPY config/* config/
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .

RUN mix release --env=prod --verbose --no-tar

FROM debian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    libssl1.0.0 \
    && export LANG=en_US.UTF-8 \
    && echo $LANG UTF-8 > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=$LANG \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8


COPY --from=builder /opt/happy_todo/_build/prod/rel/happy_todo /opt/happy_todo

ENTRYPOINT ["/opt/happy_todo/bin/happy_todo"]
