#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

JSON_RESULT=$(curl -s "http://127.0.1.1:3010/authenticate" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data @<(cat <<EOF
{
   "apikey": "795359dd2c81fa41af67faa2f9adbd32"
  }
EOF
) 2>/dev/null)

TOKEN=$(echo $JSON_RESULT|php -r 'echo json_decode(fgets(STDIN))->token;')

function initialise_type {
curl -s "http://127.0.1.1:3010/api" -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data @<(cat <<EOF
{
      "index":"e7df7cd2ca07f4f1ab415d457a6e1c13",
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
      "index":"e7df7cd2ca07f4f1ab415d457a6e1c13",
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

for TYPE in $arr
do
(
    initialise_type $TYPE
)
done
