FROM hexpm/elixir:1.19.2-erlang-28.1.1-debian-bookworm-20250417-slim as builder

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

COPY lib lib
COPY priv priv
COPY assets assets
COPY config config

RUN mix deps.compile

RUN mix assets.deploy
RUN mix compile
RUN mix release

FROM debian:bookworm-slim

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"

COPY --from=builder /app/_build/prod/rel/party_jukebox ./

CMD ["/app/bin/server"]