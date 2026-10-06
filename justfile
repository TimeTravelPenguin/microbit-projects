set dotenv-load := true
set dotenv-required := true

# List available recipes.
default:
    @just --list


# Build and run a Cargo workspace package, with Pushover notifications.
run name *args:
    #!/usr/bin/env bash
    set -uo pipefail

    notify() {
        local title="$1"
        local message="$2"

        if ! curl \
            --silent \
            --show-error \
            --fail \
            --form-string "token=$PUSHOVER_TOKEN" \
            --form-string "user=$PUSHOVER_USER" \
            --form-string "title=$title" \
            --form-string "message=$message" \
            https://api.pushover.net/1/messages.json \
            >/dev/null
        then
            echo "Warning: failed to send Pushover notification." >&2
        fi

        # A notification failure should not change the status of the actual job.
        return 0
    }

    # Ensure credentials exist before starting a potentially long job.
    : "${PUSHOVER_TOKEN:?PUSHOVER_TOKEN is not set}"
    : "${PUSHOVER_USER:?PUSHOVER_USER is not set}"

    echo "Building {{name}}..."

    cargo build --release --package "{{name}}"
    status=$?

    if (( status == 0 )); then
        notify \
            "Build succeeded: {{name}}" \
            "Release build completed successfully."
    else
        notify \
            "Build failed: {{name}}" \
            "Release build failed with exit status $status."

        exit "$status"
    fi

    echo "Running {{name}}..."

    cargo run --release --package "{{name}}" -- {{ args }}
    status=$?

    if (( status == 0 )); then
        notify \
            "Run completed: {{name}}" \
            "Process exited successfully."
    else
        notify \
            "Run failed: {{name}}" \
            "Process exited with status $status."
    fi

    exit "$status"
