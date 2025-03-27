#! /bin/bash

done=false

echo waiting for: $*

host=${1?}
shift
health_path=${1?}
shift
ports=$*

if [ -z "$ports" ] ; then
	echo no ports
	exit 99
fi

iterations=0

while [[ "$done" = false ]]; do
	for port in $ports; do
		curl --fail http://${host}:${port}${health_path} >& /dev/null
		if [[ "$?" -eq "0" ]]; then
			done=true
		else
			done=false

			if [ "$iterations" == "300" ] ; then
			  echo Too many iterations
			  exit 1
			else
			  let "iterations=$iterations + 1"
			fi
			break
		fi
	done
	if [[ "$done" = true ]]; then
		echo connected
		break;
  fi
	echo -n .
	sleep 1
done
