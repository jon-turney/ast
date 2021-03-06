########################################################################
#                                                                      #
#               This software is part of the ast package               #
#          Copyright (c) 1982-2012 AT&T Intellectual Property          #
#                      and is licensed under the                       #
#                 Eclipse Public License, Version 1.0                  #
#                    by AT&T Intellectual Property                     #
#                                                                      #
#                A copy of the License is available at                 #
#          http://www.eclipse.org/org/documents/epl-v10.html           #
#         (with md5 checksum b35adb5213ca9657e911e9befb180842)         #
#                                                                      #
#              Information and Software Systems Research               #
#                            AT&T Research                             #
#                           Florham Park NJ                            #
#                                                                      #
#                    David Korn <dgkorn@gmail.com>                     #
#                                                                      #
########################################################################

# Test for variable reset leak #
function test_reset
{
    integer i n=$1

    for ((i = 0; i < n; i++))
    do
        u=$i
    done
}


typeset -A foo
typeset -lui i=0

init_vsz=$(ps -o vsz $$ | tail -n 1 | tr -d '\n')

for (( i=0; i<50000; i++ ))
do
    unset foo[bar]
    typeset -A foo[bar]
    foo[bar][elem0]="data0"
    foo[bar][elem1]="data1"
    foo[bar][elem2]="data2"
    foo[bar][elem3]="data3"
    foo[bar][elem4]="data4"
    foo[bar][elem5]="data5"
    foo[bar][elem6]="data6"
    foo[bar][elem7]="data7"
    foo[bar][elem8]="data8"
    foo[bar][elem9]="data9"
    foo[bar][elem9]="data9"
done

curr_vsz=$(ps -o vsz $$ | tail -n 1 | tr -d '\n')

if [[ $init_vsz -lt $curr_vsz ]];
then
    log_error "Memory leak on associative array"
fi

# Test for leak in executing subshell after PATH is reset
init_vsz=$(ps -o vsz $$ | tail -n 1 | tr -d '\n')

for (( i=0; i<10000; i++ ))
do
    PATH=.
    for DIR in /usr/bin /usr/sbin /bin /usr/local/bin
    do
        if [ -d ${DIR} ]
        then
            PATH=${PATH}:${DIR}
        fi
        time=$(date +%T)
    done
done

curr_vsz=$(ps -o vsz $$ | tail -n 1 | tr -d '\n')

if [[ $init_vsz -lt $curr_vsz ]];
then
    log_error "Memory leak in executing subshell after PATH is reset"
fi

log_info 'TODO: Enable these tests when vmstate is a builtin'

#builtin vmstate 2>/dev/null || exit 0
## one round to get to steady state -- sensitive to -x
#
#n=1000
#test_reset $n
#a=0$(vmstate --format='+%(size)u')
#b=0$(vmstate --format='+%(size)u')
#
#test_reset $n
#a=0$(vmstate --format='+%(size)u')
#test_reset $n
#b=0$(vmstate --format='+%(size)u')
#
#if    (( b > a ))
#then    log_error "variable value reset memory leak -- $((b-a)) bytes after $n iterations"
#fi
#
## buffer boundary tests
#
#for exp in 65535 65536
#do    got=$($SHELL -c 'x=$(printf "%.*c" '$exp' x); print ${#x}' 2>&1)
#    [[ $got == $exp ]] || log_error "large command substitution failed -- expected $exp, got $got"
#done
#
#data="(v=;sid=;di=;hi=;ti='1328244300';lv='o';id='172.3.161.178';var=(k='conn_num._total';u=;fr=;l='Number of Connections';n='22';t='number';))"
#read -C stat <<< "$data"
#for ((i=0; i < 1; i++))
#do    print -r -- "$data"
#done |    while read -u$n -C stat
#    do    :
#    done    {n}<&0-
#a=0$(vmstate --format='+%(size)u')
#for ((i=0; i < 500; i++))
#do    print -r -- "$data"
#done |    while read -u$n -C stat
#    do    :
#    done    {n}<&0-
#b=0$(vmstate --format='+%(size)u')
#(( b > a )) && log_error 'memory leak with read -C when deleting compound variable'
#
#read -C stat <<< "$data"
#a=0$(vmstate --format='+%(size)u')
#for ((i=0; i < 500; i++))
#do      read -C stat <<< "$data"
#done
#b=0$(vmstate --format='+%(size)u')
#(( b > a )) && log_error 'memory leak with read -C when using <<<'
#
