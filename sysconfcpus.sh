#!/bin/bash

echo "Running elm-make with sysconfcpus -n 2"

/sysconfcpus/bin/sysconfcpus -n 2 elm-make-old "$@"
