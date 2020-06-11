#!/bin/bash +x
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#set -e

for pidFile in `find $CDIR -name server.pid`
do
   if [ ! -f $pidFile ]; then
      echo "\"$pidFile\" is not a file"
   fi
   pid=`cat $pidFile`
   dir=$(dirname $pidFile)
   echo "Stopping CA server in $dir with PID $pid ..."
   if ps -p $pid > /dev/null
   then
      kill -9 $pid
      wait $pid 2>/dev/null
      rm -f $pidFile
      echo "Stopped CA server in $dir with PID $pid"
   fi
done

