#!/bin/sh

### Temporary files

tmpconfig="$(mktemp --suffix=.yaml)"
tmpconfigjson="$(mktemp --suffix=.json)"
tmphydra="$(mktemp --suffix=.yaml)"

### Functions

# Cleanup function to remove temporary files
cleanup() {
	rm --force "${tmpconfig}" "${tmpconfigjson}" "${tmphydra}"
}

# Function to fill values in the configuration file
fillconfig() {
	gomplate \
		--file src/config.yaml.tpl \
		--out "${1}"
}

# Function to convert configuration file to JSON
convertconfig() {
	yq --output-format json eval '.' "${1}" >"${2}"
}

# Function to fill values in the Ory Hydra configuration file
fillhydra() {
	gomplate \
		--file src/hydra.yaml.tpl \
		--datasource config="${1}" \
		--out "${2}"
}

# Migration function
migrate() {
	# shellcheck disable=SC2312
	hydra \
		migrate \
		sql \
		up \
		--yes \
		--config "${1}" \
		"$(yq eval '.dsn' "${1}")"
}

# Function to setup ignoring signals
ignoresignals() {
	for signal in INT TERM HUP QUIT; do
		trap '' "${signal}"
	done
}

# Function to start Ory Hydra
starthydra() {
	# shellcheck disable=SC2046,SC2312
	hydra \
		serve \
		all \
		--sqa-opt-out \
		$([ "$(yq eval '.debug' "${1}")" = "true" ] && echo "--dev") \
		--config "${2}" \
		&
}

# Function to kill a process silently
silentkill() {
	kill -"${1}" "${2}" >/dev/null 2>&1 || true
}

# Function to wait and exit gracefully
waitexit() {
	wait "${1}"
	status=$?
	cleanup
	exit "${status}"
}

# Function to setup signal handling
handlesignals() {
	for signal in INT TERM HUP QUIT; do
		# shellcheck disable=SC2064
		trap "silentkill ${signal} '${1}'; waitexit '${1}'" "${signal}"
	done
}

# Configuration function
configure() {
	python src/configure.py "${1}"
}

### Main script execution

# Fill values in the configuration file
fillconfig "${tmpconfig}"

# Convert the configuration file to JSON
convertconfig "${tmpconfig}" "${tmpconfigjson}"

# Fill values in the Ory Hydra configuration file
fillhydra "${tmpconfig}" "${tmphydra}"

# Run migrations
if ! migrate "${tmphydra}"; then
	cleanup
	exit 1
fi

# Temporarily ignore signals
ignoresignals

# Start Ory Hydra in the background
starthydra "${tmpconfig}" "${tmphydra}"

# Setup signal handling
pid=$!
handlesignals "${pid}"

# Configure Ory Hydra
if ! configure "${tmpconfigjson}"; then
	silentkill TERM "${pid}"
	waitexit "${pid}"
fi

# Wait for Ory Hydra to exit
waitexit "${pid}"
