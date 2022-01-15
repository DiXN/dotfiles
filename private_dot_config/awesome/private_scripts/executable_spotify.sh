#! /usr/bin/env bash

PATTERN="(.+) - (.*)"

function generate_token {
  spt list --devices
}

if [[ "$1" == "album" ]]; then
  # Get BEARER token form spotify tui cache.
  generate_token
  BEARER="$(jq -r ".access_token" "/home/$(whoami)/.config/spotify-tui/.spotify_token_cache.json")"
  mkdir -p "/tmp/spot"
  ALBUM_PATH="/tmp/spot/album.png"

  if [ -n "$BEARER" ]; then
    # Get Current Album ID.
    ALBUM_ID="$(spt playback --share-album | awk 'BEGIN { FS = "/" }; {print $5}')"
    # Get Album image and print save it in temporary folder.
    ALBUM_IMG=$(curl -s -X "GET" "https://api.spotify.com/v1/albums/$ALBUM_ID" \
     -H "Accept: application/json" -H "Content-Type: application/json" \
     -H "Authorization: Bearer $BEARER" | jq -r ".images[1].url")
    curl -sL "$ALBUM_IMG" > "$ALBUM_PATH" && echo "$ALBUM_PATH"
  else
    # Fallback version in case no BEARER token is available
    ALBUM_IMG=$(curl -sL "$(spt playback --share-album)" | pcregrep -o1 "src=\"(https:\/\/i\.scdn\.co\/image\/.*?)\"" | head -n 1)
    # ALBUM_ID=$(echo "$ALBUM_IMG" | awk 'BEGIN { FS = "/" }; {print $5}')
    # ALBUM_PATH="/tmp/spot/${ALBUM_ID}.png"
    curl -sL "$ALBUM_IMG" > "$ALBUM_PATH" && echo "$ALBUM_PATH"
  fi
elif [[ "$1" == "recommend" ]]; then
  # Get BEARER token form spotify tui cache.
  generate_token
  BEARER="$(jq -r ".access_token" "/home/$(whoami)/.config/spotify-tui/.spotify_token_cache.json")"

  if [ "$2" == "--artist" ]; then
    # URL-encode search request.
    QUERY="$(printf %s "$3" | jq -sRr @uri)"

    # Get Artist ID.
    ARTIST=$(curl -s -X "GET" "https://api.spotify.com/v1/search?q=$QUERY&type=artist" -H \
      "Accept: application/json" -H "Content-Type: application/json" \
      -H "Authorization: Bearer $BEARER" | jq -r ".artists.items[0].id")

    while IFS=, read -r NAME URI; do
      sleep 1

      # Check if spotifyd is online and if API request is successfull.
      [[ "$(spt play -q --uri "$URI" 2>&1)" =~ .*[Ee]rror.* ]] && \
        [[ "$(spt play -t --uri "$URI" 2>&1)" =~ .*[Ee]rror.* ]] && \
          echo "Spotifyd is probably not running." && \
            notify-send "Spotifyd is probably not running." && exit 1

      echo "Queuing: $NAME"
      notify-send "Queuing: $NAME"
    # Map spotify recommendations API call to track name and uri.
    done < <(curl -s -X "GET" "https://api.spotify.com/v1/recommendations?seed_artists=6mdiAmATAx73kdxrNrnlao" -H \
      "Accept: application/json" -H "Content-Type: application/json" \
      -H "Authorization: Bearer $BEARER" | jq -r '.tracks | map("\(.name),\(.uri)") | .[]')
  else
    echo 'Use "recommend" with "--artist" flag since nothing else is currently supported.'
  fi
elif [[ "$1" == "song" ]]; then
  PLAYING="$(spt playback -s)"
  SONG="$(echo "$PLAYING" | pcregrep -o1 "$PATTERN")"
  [[ "${SONG::1}" == "🔀" ]] && SONG=${SONG:2}
  echo "${SONG:2}"
elif [[ "$1" == "artist" ]]; then
  PLAYING="$(spt playback -s)"
  ARTIST="$(echo "$PLAYING" | pcregrep -o2 "$PATTERN")"
  echo "$ARTIST"
else
  PLAYING="$(spt playback -s 2>&1)"
  ARTIST="$(echo "$PLAYING" | pcregrep -o2 "$PATTERN")"
  SONG="$(echo "$PLAYING" | pcregrep -o1 "$PATTERN")"
  [[ "${SONG::1}" == "🔀" ]] && SONG=${SONG:2}

  if [[ ${SONG::1} == "▶" ]]; then
    echo 'playing'
    echo "${SONG:2}"
    echo "$ARTIST"
  elif [[ $PLAYING == "Error: no context available" ]]; then
    echo 'not playing'
    echo 'Nothing Playing'
    echo ''
  else
    echo 'not playing'
    echo "${SONG:2}"
    echo "$ARTIST"
  fi
fi


