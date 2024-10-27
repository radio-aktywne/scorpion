#!/bin/sh

tmpconfig="$(mktemp --suffix=.yaml)"

# Fill values in the configuration file
gomplate \
	--file src/config.yaml.tpl \
	--out "${tmpconfig}"

tmphydra="$(mktemp --suffix=.yaml)"

# Fill values in the Ory Hydra configuration file
gomplate \
	--file src/hydra.yaml.tpl \
	--datasource config="${tmpconfig}" \
	--out "${tmphydra}"

# Run migrations
# shellcheck disable=SC2312
hydra \
	migrate \
	sql \
	--yes \
	--config "${tmphydra}" \
	"$(yq eval '.dsn' "${tmphydra}")"

# Start Ory Hydra
# shellcheck disable=SC2046,SC2312
hydra \
	serve \
	all \
	--sqa-opt-out \
	$([ "$(yq eval '.debug' "${tmpconfig}")" = "true" ] && echo "--dev") \
	--config "${tmphydra}"
