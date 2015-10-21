#!/bin/bash

if [ "$PWD" != "${PWD#/home/rciorba/repos/}" ]
then
    path="${PWD#/home/rciorba/repos/}"
    ve="${path%%/*}"
    which erlc
    /home/rciorba/repos/$ve/env/bin/escript `which eflymake.erl` $@
fi
true
