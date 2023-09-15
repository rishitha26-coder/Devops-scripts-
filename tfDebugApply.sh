#!/bin/bash

TF_LOG=trace terraform apply -auto-approve -parallelism=1 2>&1 | tee terraformapply.log | tail -n ${1:-50}
