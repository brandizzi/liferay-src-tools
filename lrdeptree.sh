#!/usr/env bash

MODULES=${1:-$(mktemp)}
PROJECT_HOME=${2:-$PROJECT_HOME}
C=0

function getdeps() {
  bg=$1/build.gradle
  sed -n 's#:#/#g;s|.*project("\(.*\)").*|'$PROJECT_HOME'/modules\1|p' $bg \
      | sed 's#//#/#g'
}

function lrdeptree() {
  t=$(mktemp)
  while read m
  do
    m="$m/"
    if [  "$(grep "$m" $MODULES)" ]
    then
      continue
    else
      echo $m >> $MODULES
    fi
    C=$((C+1))
    getdeps $m | lrdeptree # $t
    C=$((C-1))
  done
}

xargs -L1 realpath  | lrdeptree
sort -u $MODULES
