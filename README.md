# Build
Build the Dockerfile with

```docker build . -t test-honeybee```

# Debug
Enter the docker image with a shell to poke around manually with:

```docker run --rm -it test-honeybee```

Note that images don't include running processes; you'll need to restart the
postgresql service from inside with:

```sudo service postgresql start```
