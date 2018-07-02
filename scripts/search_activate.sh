#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../htdocs/admin/ && pwd)

# Activate search index

JSON_RESULT=$(curl -s "http://127.0.1.1:3010/authenticate" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data @<(cat <<EOF
{
   "apikey": "795359dd2c81fa41af67faa2f9adbd32"
  }
EOF
) 2>/dev/null)

TOKEN=$(echo $JSON_RESULT|php -r 'echo json_decode(fgets(STDIN))->token;')

curl -s "http://127.0.1.1:3010/api/e7df7cd2ca07f4f1ab415d457a6e1c13/activate" -H "Authorization: Bearer $TOKEN" 2>/dev/null


# Activate shared indexes

JSON_RESULT=$(curl -s "http://127.0.1.1:3010/authenticate" -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data @<(cat <<EOF
{
   "apikey": "88cfd4b277f3f8b6c7c15d7a84784067"
  }
EOF
) 2>/dev/null)

TOKEN=$(echo $JSON_RESULT|php -r 'echo json_decode(fgets(STDIN))->token;')

curl "http://127.0.1.1:3010/api/bibshare/activate" -H "Authorization: Bearer $TOKEN"
curl "http://127.0.1.1:3010/api/itkdevshare/activate" -H "Authorization: Bearer $TOKEN"
