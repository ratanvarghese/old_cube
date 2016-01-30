#!/usr/bin/bash
for f in ./test/*.lua; do ./main --test ${f}; done
