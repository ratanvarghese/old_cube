#!/usr/bin/bash
for f in ./test/_*.lua; do ./main --test ${f}; done
