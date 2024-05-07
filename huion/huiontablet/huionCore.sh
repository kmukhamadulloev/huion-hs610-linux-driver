#!/bin/bash
appname=`basename $0 | sed s,\.sh$,,`
dirname=`dirname $0`
tmp="${dirname#?}"
if [ "${dirname%$tmp}" != "/" ]; then
dirname=$PWD/$dirname
fi

echo $dirname

LD_LIBRARY_PATH=$dirname/libs
export LD_LIBRARY_PATH

echo $LD_LIBRARY_PATH

echo "$@"

echo $dirname/$appname

$dirname/$appname "$@"  -d
