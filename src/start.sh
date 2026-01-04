#!/bin/sh

### Temporary files

tmpconfig="$(mktemp --suffix=.yaml)"
tmpconfigjson="$(mktemp --suffix=.json)"
tmphydraconfig="$(mktemp --suffix=.yaml)"

### Functions

# Cleanup function to remove temporary files
cleanup() {
	rm --force "${tmpconfig}" "${tmpconfigjson}" "${tmphydraconfig}"
}

# Function to fill values in the configuration file
fillconfig() {
	gomplate --file src/config.yaml.tpl --out "${1}"
}

# Function to fill values in the Ory Hydra configuration file
fillhydraconfig() {
	gomplate --file src/hydra.yaml.tpl --datasource config="${1}" --out "${2}"
}

# Function to convert configuration file to JSON
convertconfig() {
	yq --output-format json eval '.' "${1}" >"${2}"
}

# Function to setup ignoring signals
ignoresignals() {
	for signal in INT TERM HUP QUIT; do
		trap '' "${signal}"
	done
}

# Function to start migrations
startmigrations() {
	dsn="$(yq eval '.dsn' "${1}")"

	echo "Running migrations..."

	hydra migrate sql up --yes --config "${1}" "${dsn}" &
}

# Function to start Ory Hydra
starthydra() {
	debug="$(yq eval '.debug' "${1}")"

	echo "Starting Ory Hydra..."

	# shellcheck disable=SC2046,SC2312
	hydra serve all --sqa-opt-out $([ "${debug}" = "true" ] && echo "--dev") --config "${2}" &
}

# Function to setup signal handling
handlesignals() {
	for signal in INT HUP; do
		trap 'kill -TERM '"${1}"'; wait '"${1}"'; status=$?; cleanup; exit "${status}"' "${signal}"
	done

	for signal in TERM QUIT; do
		trap 'kill -'"${signal}"' '"${1}"'; wait '"${1}"'; status=$?; cleanup; exit "${status}"' "${signal}"
	done
}

# Function to configure Ory Hydra
configure() {
	python src/configure.py "${1}"
}

# Function to wait for Ory Hydra to exit and handle cleanup
waitandcleanup() {
	wait "${1}"
	status=$?

	# Cleanup temporary files
	cleanup

	exit "${status}"
}

### Main script execution

# Fill values in files
fillconfig "${tmpconfig}"
fillhydraconfig "${tmpconfig}" "${tmphydraconfig}"

# Convert configuration file to JSON
convertconfig "${tmpconfig}" "${tmpconfigjson}"

# Temporarily ignore signals
ignoresignals

# Run migrations
startmigrations "${tmphydraconfig}"

# Setup signal handling
pid=$!
handlesignals "${pid}"

# Wait for migrations to complete
wait "${pid}"

# Temporarily ignore signals
ignoresignals

# Start Ory Hydra in the background
starthydra "${tmpconfig}" "${tmphydraconfig}"

# Setup signal handling
pid=$!
handlesignals "${pid}"

# Configure Ory Hydra
if ! configure "${tmpconfigjson}"; then
	kill -TERM "${pid}" >/dev/null 2>&1
fi

# Wait for Ory Hydra to exit
waitandcleanup "${pid}"
