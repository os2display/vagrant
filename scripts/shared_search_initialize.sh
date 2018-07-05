#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

JSON_RESULT=$(curl -s "http://127.0.1.1:3010/authenticate" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data @<(cat <<EOF
{
   "apikey": "88cfd4b277f3f8b6c7c15d7a84784067"
  }
EOF
) 2>/dev/null)

TOKEN=$(echo $JSON_RESULT|php -r 'echo json_decode(fgets(STDIN))->token;')

function initialise_type {
curl -s "http://127.0.1.1:3010/api" -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data @<(cat <<EOF
{
      "index":"$2",
      "type":"$1",
      "id":1,
      "data": {
        "name": "test",
        "user": 1,
        "created_at": 0
      }
}
EOF
)

curl -s "http://127.0.1.1:3010/api" -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" -H "Content-Type:application/json" -X DELETE --data @<(cat <<EOF
{
      "index":"$2",
      "type":"$1",
      "id":1
}
EOF
)
}

arr="Os2Display\\\\CoreBundle\\\\Entity\\\\Slide
Os2Display\\\\CoreBundle\\\\Entity\\\\Channel
Os2Display\\\\CoreBundle\\\\Entity\\\\Screen
Os2Display\\\\MediaBundle\\\\Entity\\\\Media"

indexes="bibshare
itkdevshare"

for INDEX in $indexes
do
(
    for TYPE in $arr
    do
    (
        initialise_type $TYPE $INDEX
    )
    done
)
done
