#!/usr/bin/bash
for f in ./test/*.lua; do ./main -t ${f}; done
