#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Usage: <mode> <github username> <gist filename>" >&2
    echo "   mode is:" >&2
    echo "     -o output the file to stdout" >&2
    echo "     -s store the file in a temporary location, and print the temp filename" >&2
    echo "     -x execute the script" >&2
    echo "        (to pass arguments to the downloaeded script, add a \"-\" and add" >&2
    echo "         add the args for the downloaded script after that)" >&2
    exit 1
fi

CURL='curl -L -#'
# run through arguments
i=0
grab=0
mode=0 # 0 - execute, 1 - cat, 2 - store (and print the resulting filename)
for opt in "$@"; do
  case "$opt" in
    -)
       grab=1
       ;;
    -o)
       mode=1
       ;;
    -s)
       mode=2
       ;; 
    -x)
       mode=0
       ;;
    *)
    if [ $grab -eq 1 ]; then
      arg[i]="$opt" # passed to downloaded script at the bottom
    fi
    i=$((i+1))
    ;;
  esac
done

# Check if JSON.sh has been downloaded
if ! [ -f /tmp/.gister_JSON.sh ]; then
    echo "Downloading JSON.sh" >&2
    $CURL https://raw.github.com/dominictarr/JSON.sh/master/JSON.sh > /tmp/.gister_JSON.sh
fi

USER=$2
GIST=$3

# I don't understand why saving the result to a var doesn't work in zsh
#GISTS_RESULT=$(curl https://api.github.com/users/$USER/gists)
echo "Find Gist" >&2
$CURL https://api.github.com/users/$USER/gists > /tmp/.gister_gists_result
if [ $? -ne 0 ]; then
   echo "Cannot communicate with github." >&2
   exit 1
fi

# I don't understand why saving the result to a var doesn't work in zsh
#GISTS_JSON=$(echo $GISTS_RESULT | bash /tmp/.gister_JSON.sh)
cat /tmp/.gister_gists_result | bash /tmp/.gister_JSON.sh > /tmp/.gister_gists_parsed
if [ $? -ne 0 ]; then
    echo "Error parsing JSON." >&2
    exit 1
fi

#echo "JSON: $GISTS_JSON"
GIST_URL=$(cat /tmp/.gister_gists_parsed | grep -v "\[\]" | grep '\[[0-9]\+,"files"]' | grep $GIST | awk -F ' ' '{ print $2 }' | cut -d ':' -f 2- | sed "s;}};;" | sed "s;{;;"  | sed "s;,;\n;g" | awk 'BEGIN { FS=":" } $1 == "\"raw_url\"" { print $2 ":" $3 } ' | sed 's;";;g' | sed 's; ;:;g')
if [ $? -ne 0 ]; then
   echo "Problem parsing github response." >&2
   exit 1
fi

if [ ! -n "$GIST_URL" ]; then
   echo "Did not found any gists for user $USER with name $GIST." >&2
   echo "You can review the data parsed at /tmp/.gister_json" >&2
   echo $GISTS_JSON > /tmp/.gister_json 
   exit 1
fi

NUM_GISTS=$(echo $GIST_URL | wc -l)
if [ $NUM_GISTS -ne 1 ]; then
   echo "Found multiple gists. Please unambiguify the choice." >&2
   echo "$GIST_URL" >&2
   exit 1
fi

echo "Get  Gist" >&2
$CURL $GIST_URL > /tmp/.gister_${GIST}.sh

if [ $mode -eq 0 ]; then
  echo >&2
  echo >&2
  chmod a+x /tmp/.gister_${GIST}.sh
  /tmp/.gister_${GIST}.sh ${arg[@]}
fi
if [ $mode -eq 1 ]; then
  cat /tmp/.gister_${GIST}.sh
fi
if [ $mode -eq 2 ]; then
  TMP=$(mktemp)
  mv /tmp/.gister_${GIST}.sh $TMP
  echo $TMP
fi

