#!/bin/bash
folderName=$1
executable=$2
currentLocation=`pwd`
shift 2
cd $folderName
make
isMake=$?
if [ "$isMake" -gt "0" ] ; then
        echo "Compilation FAIL"
        cd $currentLocation
        exit 7
fi


valgrind --leak-check=full --error-exitcode=1 ./$executable $@ &> /dev/null
valgrindgout=$?
if [ "$valgrindgout" -eq "0" ] ; then
        error=0
else
        error=1
fi

valgrind --tool=helgrind --error-exitcode=1 ./$executable $@ &> /dev/null
race=$?
if [ "$race" -eq "0" ] ; then
        isRace=0
else
        isRace=1
fi


status=$error$isRace
cd $currentLocation
if [ "$status" -eq "00" ] ; then
        echo "Compilation PASS  Memory leaks PASS       Tread race PASS"
        exit 0
elif [ "$status" -eq "10" ] ; then
        echo "Compilation PASS  Memory leaks FAIL       Tread race PASS"
        exit 2
elif [ "$status" -eq "01" ] ; then
        echo "Compilation PASS  Memory leaks PASS       Tread race FAIL"
        exit 1
else
        echo "Compilation PASS  Memory leaks FAIL       Tread race FAIL"
        exit 3
fi
