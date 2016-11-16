#!/bin/bash

urlist=$(wget -q -O - "$1" | sed -e "s/</\\n/g" | grep "title may-blank" | cut -d '"' -f 6)

usrname=$(echo $1 | cut -d "/" -f 5)
mkdir -p $usrname
cd $usrname
mkdir -p images
mkdir -p gifs

for var in $urlist
do
  if [[ $var == *"i.imgu"* ]]; then
    wget -nc -nv -P ./images/ $var
  elif [[ $var == *"imgur.com/a/"* ]]; then
    aID=$(echo $var | cut -d "/" -f 5)
    wget -nc -nv -O "./images/$aID.zip" "https://s.imgur.com/a/$aID/zip"
  elif [[ $var == *"gfyca"* ]]; then
    wget -nc -nv -P ./gifs/ $(wget -q -O - $var | sed -e "s/</\\n/g" | grep webmSource | cut -d '"' -f 4)
  fi  
done

nextpg=$(wget -q -O - "$1" | sed -e "s/</\\n/g" | grep "nofollow next")

if [ $? -eq 0 ]; then
  cd ..
  ./redditDL.sh $(echo "$nextpg" | cut -d '"' -f 2)
else
  cd images
  for f in *.zip; do
    mkdir "$f-dir" && unzip -d "$f-dir" $f && rm $f && cd "$f-dir" && for j in *; do
      #echo "$j $f ${j%%.*}"
      mv "$j" "../${f%%.*}-$j"
      
    done && cd .. && rmdir "$f-dir"
  done
fi

