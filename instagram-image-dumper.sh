#!/bin/bash
#
# dumper.sh - A simple Instagram Pic Dumper using jq
#
# Copyright (c) 2014 by klassiker <echo a2xhc3Npa2Vya2xhc3Npa2VyQGxpdmUuZGUK | base64 -d>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/
#
#======================================================================
# Author: klassiker
# Email : echo a2xhc3Npa2Vya2xhc3Npa2VyQGxpdmUuZGUK | base64 -d
# Github: www.github.com/klassiker

# Init
# account_name is also the directory where the pics will be dumped
# account_name = "$1"
wget -q "http://instagram.com/${1}/media" -O media

if [[ ! "$1" ]]
then
  echo "No Instagram Account"
  exit
fi
if [[ ! -d "$1" ]]
then
  mkdir "$1"
fi

# Do a loop until no media is available
while :
do
  more_available=$(jq ".more_available" media)
  #jq ".items[].images.standard_resolution.url" media | sed 's/\"\(.*\)\"/\1/g' >> urls
  surl=`jq ".items[].images.standard_resolution | select(.width > 400) | .url" media | sed 's/\"\(.*\)\"/\1/g'`
  readarray array <<< "$surl"
  for eu in "${array[@]}"
  do
    echo $eu
    ddir=`echo $eu | sed 's/\/[^\/]*//4g'`
    simg=`echo "${eu##*/}"`
    if [ ! -z "$ddir" ];
    then
      echo $ddir"/"$simg >> urls
    fi
  done
  if [[ $more_available == "true" ]]
  then
    last_id=$(jq ".items[19].id" media | sed 's/\"\(.*\)\"/\1/g')
    rm media
    echo "$last_id"
    wget -q "http://instagram.com/${1}/media?max_id=${last_id}" -O media
  else
    break
  fi
done

rm media

# Now download
mv urls "$1"/urls
cd "$1"
while read line
do
  fname=$(echo "$line" | sed 's/.*\/\(.*\.jpg\)/\1/g')
  if [[ ! -e "$fname" ]]
  then
    echo "$line" >> newurls
  fi
done < urls
if [[ -e newurls ]]
then
  wget -nv -i newurls
  rm newurls
fi
if [[ -e urls ]]
then
  rm urls
fi
cd ..
