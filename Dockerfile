FROM bitwalker/alpine-elixir-phoenix:1.9.4 as build
COPY . /opt/app
WORKDIR /opt/app
RUN mix do \
  local.hex --force, \
  local.rebar --force, \
  deps.get --only prod, \
  deps.compile
ENV MIX_ENV=prod
RUN mix release orchestrate \
  && mix release gather \
  && mix release broadcast \
  && mix release persist \
  && mix release acquire

FROM bitwalker/alpine-erlang:22.2.3
WORKDIR /opt/app
COPY --from=build /opt/app/_build/prod/rel/ .
