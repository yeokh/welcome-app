#!/usr/bin/env bash

APP_NAME=welcome-app

SCRIPT_DIR=$(cd "$(dirname "$BASH_SOURCE")" ; pwd -P)

OK=1
for arg in "$@"; do
    case "$arg" in
        "deploy"|"build"|"clean"|"push"|"delete")
            CMD=$arg
            ;;
        -*)
            [[ "$CMD" == "push" ]] || OK=0
            ;;
        *)
            OK=0
            ;;
    esac
done

if [[ $# > 0 && $OK == 1 ]]; then
    if [[ $1 == "delete" ]]; then
        shift
        oc delete all,secrets -l app=${APP_NAME}
    fi

    if [[ $# > 0 ]]; then
        for file in ${SCRIPT_DIR}/*/gap; do
            DIR=$(basename $(dirname "$file"))
            echo "Part '$DIR'..."
            pushd >/dev/null "$DIR"
            $file "$@"
            RES=$?
            popd >/dev/null
            if [[ $RES > 0 ]]; then
                exit $RES
            fi
        done
    fi
else
    echo "Usage: gap [deploy|build|clean|push|delete] ..."
    echo "   deploy  - Deploys the application to OpenShift"
    echo "   build   - Builds the application from code"
    echo "   clean   - Cleans any build artifacts"
    echo "   push    - Pushes code to the application. By default this will push the pe-compiled"
    echo "             binary if it exists, otherwise it will push the local sources to be compiled"
    echo "             on OpenShift. This can be overridden by using one of the following flags:"
    echo "      -b, --binary - Pushes a pre-compiled binary"
    echo "      -s, --source - Pushes the sources"
    echo "      -g, --git    - Reverts to using the sources from Git"
    echo "   delete  - Deletes the application from OpenShift"
fi
