#!/bin/bash

# get ham- and spamboxes
IFS=',' read -r -a learnhamboxes <<< "$LEARNHAMBOXES"
IFS=',' read -r -a learnspamboxes <<< "$LEARNSPAMBOXES"

# run spamd
/usr/sbin/spamd -d -D --allow-tell --create-prefs --max-children 5 --helper-home-dir #-u appuser -g appuser -p 7783

# counter for updating spam rules
i=11

# loop
while true; do
  # check spamd status
  ps aux |grep spamd |grep -q -v grep
  if [ $? -ne 0 ]; then
    echo "error: spamd does not seem to be running"
    exit 1
  fi

  # every hour
  if [ $i -le 0 ]; then
    # update spam assassin rules
    sa-update
    sa-update --nogpg --channel spamassassin.heinlein-support.de
    i=11
  fi

  # learn all hamboxes
  for box in "${learnhamboxes[@]}"; do
    isbg \
      --imaphost="$IMAPHOST" \
      --imapuser="$IMAPUSER" \
      --imappasswd="$IMAPPASSWD" \
      --spamc \
      --noninteractive \
      --trackfile="/track/$TRACKFILE" \
      --learnhambox="$box" \
      --teachonly
  done

  # learn all spamboxes
  for box in "${learnspamboxes[@]}"; do
    isbg \
      --imaphost="$IMAPHOST" \
      --imapuser="$IMAPUSER" \
      --imappasswd="$IMAPPASSWD" \
      --spamc \
      --noninteractive \
      --trackfile="/track/$TRACKFILE" \
      --learnspambox="$box" \
      --learnthendestroy \
      --teachonly
  done

  isbg \
    --imaphost="$IMAPHOST" \
    --imapuser="$IMAPUSER" \
    --imappasswd="$IMAPPASSWD" \
    --spamc \
    --noninteractive \
    --trackfile="/track/$TRACKFILE" \
    --noreport #--delete

  # decrease counter
  ((i=i-1))

  # sleep for 5 minutes
  sleep 300
done