#!/bin/sh

tmpconfig="$(mktemp --suffix=.yaml)"

# Fill values in the configuration file
gomplate \
	--file src/config.yaml.tpl \
	--out "${tmpconfig}"

tmpconfigjson="$(mktemp --suffix=.json)"

# Convert the configuration file to JSON
yq --output-format json eval '.' "${tmpconfig}" >"${tmpconfigjson}"

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
	up \
	--yes \
	--config "${tmphydra}" \
	"$(yq eval '.dsn' "${tmphydra}")"

# Start Ory Hydra in the background
# shellcheck disable=SC2046,SC2312
hydra \
	serve \
	all \
	--sqa-opt-out \
	$([ "$(yq eval '.debug' "${tmpconfig}")" = "true" ] && echo "--dev") \
	--config "${tmphydra}" \
	&

# Configure Ory Hydra
python src/configure.py "${tmpconfigjson}"

# Wait for Ory Hydra to exit
wait

# Clean up
rm --force "${tmpconfig}" "${tmpconfigjson}" "${tmphydra}"
