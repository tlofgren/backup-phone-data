#!/bin/bash

# homedir="/home/tyler"
# MYARR=( "${homedir}/backup" "${homedir}/Desktop" )

# for el in ${MYARR[@]}; do
#     echo $el
# done

exit_if_fail() {
    local exitcode=$?
    local prog='command'
    if [ -n "$1" ]; then
        prog=$1
    fi
    if [ ${exitcode} -ne 0 ]; then
        echo "${prog} failed; exiting"
        exit ${exitcode}
    fi
}

testz() {
    local varx="initial x"
    if [ -z "$1" ]; then
        varx="$varx t";
        echo "first param empty";
    else
        varx="$varx f";
        echo "first param not empty";
    fi
    echo $varx
    return 0
}

# which blah
# ret=`exit_if_fail "which"`

echo `testz`
echo `testz "myparam"`
echo `testz "par0" "par1"`

grep
exit_if_fail "grep"

echo "did not exit"
echo "ret: $ret"
