#!/bin/bash -x

TEMPFILE=$(mktemp /var/tmp/test.XXXXXX)
filearg=
if [[ "$1" = "-f" ]] ; then
  filearg="$2"
  shift && shift
fi

args=()

while [[ "$1" == -* ]] ; do
  if [[ "$1" == -- ]] ; then
    shift
    break
  elif [[ "$2" == -* ]] ; then
    args=(${args[@]} $1)
    shift
  else
    args=(${args[@]} $1 $2)
    shift ; shift
  fi
done
docker build . ${filearg:+ -f $filearg} 2>&1 | tee ${TEMPFILE}
imageline=$(tail -n 2 ${TEMPFILE} | awk '/writing image sha256:/ {print $0}')
image="${imageline##*sha256:}"
image="${image% *}"
if [[ ! -n "$image" ]] || ! docker image inspect $image > /dev/null 2>&1 ; then
  echo "Build failed!"
  exit 1
fi
docker run --rm --name ${PWD##*/} "${args[@]}" $image "$@" < /dev/null
