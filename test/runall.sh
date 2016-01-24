#Intended to be run from project root directory
#Or, run "make check" at project root directory

for f in ./test/*; do ./main ${f}; done
