#!/bin/sh -l


if [ -z "${INPUT_TOKEN}" ]; then
    echo "error: no INPUT_TOKEN supplied"
    exit 1
fi

if [ -z "${INPUT_BRANCH_NAME}" ]; then
   export INPUT_BRANCH_NAME=generate-schema
fi


git config http.sslVerify false
git config user.name "[GitHub] - Automated Action"
git config user.email "actions@github.com"

# Remove generate-schema branch from remote if it already exists.
if [ "${INPUT_BRANCH_NAME}" != "main" ] || [  "${INPUT_BRANCH_NAME}" != "master" ]; then
  if git ls-remote --exit-code --heads origin "${INPUT_BRANCH_NAME}" >/dev/null 2>&1; then
    git push origin --delete "${INPUT_BRANCH_NAME}"
  fi
fi

# sync the input branch
git fetch
git checkout -b "${INPUT_BRANCH_NAME}" --no-track origin/master

# clone ksl-schema-language repo
git clone --depth=1 https://github.com/project-kessel/ksl-schema-language.git

# build KSL compiler binary
cd ksl-schema-language
mkdir -p bin/
go build -gcflags "all=-N -l" -o ./bin/ ./...
cd ..

# generate schema 
./ksl-schema-language/bin/ksl "${INPUT_INPUT_FILES}" -o "${INPUT_OUTPUT_FILE_PATH}" 

# remove ksl-schema-language repo
rm -rf ksl-schema-language/


# push the changes
git add .
timestamp=$(date -u)
git commit -m "[GitHub] - Automated Schema Generation: ${timestamp} - ${GITHUB_SHA}" || exit 0
git push origin ${INPUT_BRANCH_NAME}
