publish:
    devcontainer features publish src --registry ghcr.io --namespace ridgerun/devcontainer-features

docs:
    devcontainer features generate-docs -p . -n ridgerun/devcontainer-features --github-owner ridgerun --github-repo devcontainer-features --log-level debug

build:
    devcontainer up

force:
    devcontainer up --remove-existing-container

run:
    devcontainer exec --workspace-folder . bash

unpublish feature="":
    #!/usr/bin/env bash
    set -euo pipefail

    feature="{{feature}}"

    delete_package() {
        local package="$1"
        local encoded_package="${package//\//%2F}"

        printf 'Deleting ghcr.io/ridgerun/%s\n' "$package"
        gh api -X DELETE "/orgs/ridgerun/packages/container/${encoded_package}"
    }

    if [[ -n "$feature" ]]; then
        package="devcontainer-features/$feature"
        printf 'This will delete ghcr.io/ridgerun/%s and all versions.\n' "$package"
        printf 'Type DELETE to continue: '
        read -r confirmation
        if [[ "$confirmation" != "DELETE" ]]; then
            printf 'Aborted.\n' >&2
            exit 1
        fi

        delete_package "$package"
        exit 0
    fi

    mapfile -t packages < <(
        gh api --paginate /orgs/ridgerun/packages?package_type=container -q '.[] | select(.name | startswith("devcontainer-features/")) | .name'
    )

    if [[ "${#packages[@]}" -eq 0 ]]; then
        printf 'No devcontainer-features packages found.\n'
        exit 0
    fi

    printf 'This will delete all devcontainer-features packages:\n'
    printf '  %s\n' "${packages[@]}"
    printf 'Type DELETE ALL to continue: '
    read -r confirmation
    if [[ "$confirmation" != "DELETE ALL" ]]; then
        printf 'Aborted.\n' >&2
        exit 1
    fi

    for package in "${packages[@]}"; do
        delete_package "$package"
    done
