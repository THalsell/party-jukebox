#!/usr/bin/env bash
# exit on error
set -o errexit

mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy

# Build the release
MIX_ENV=prod mix release --overwrite

# Run migrations
_build/prod/rel/party_jukebox/bin/party_jukebox eval "PartyJukebox.Release.migrate"
