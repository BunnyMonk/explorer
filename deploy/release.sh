#!/usr/bin/env bash
#
# Copyright (C) 2022 diva.exchange
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Author/Maintainer: DIVA.EXCHANGE Association, https://diva.exchange
#

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../
cd ${PROJECT_PATH}
PROJECT_PATH=`pwd`

LOADED=
if [[ -f "${PROJECT_PATH}/deploy/profile/.loaded" ]]; then
  LOADED=$(<${PROJECT_PATH}/deploy/profile/.loaded)
fi

NAME_RELEASE_PROFILE=${1:-release}

if [[ ! -f "${PROJECT_PATH}/deploy/profile/${NAME_RELEASE_PROFILE}" ]]; then
    echo "${PROJECT_PATH}/deploy/profile/${NAME_RELEASE_PROFILE} for release not found"
    exit 1
fi

source "${PROJECT_PATH}/deploy/profile/${NAME_RELEASE_PROFILE}"

git checkout develop
${PROJECT_PATH}/bin/build.sh

VERSION=v$(<${PROJECT_PATH}/static/version)
echo ${VERSION}

${PROJECT_PATH}/bin/create-docker-image.sh

## Committing release stuff
git commit -a -m "build ${VERSION}"
git push origin

#git checkout main
#git pull
#git merge develop

## TAG the release
#git tag -a ${VERSION} -m "Signed Version ${VERSION}"

## Push the release
#git push origin ${VERSION}


echo "Released: ${VERSION}"

if [[ ! -z "${LOADED}" ]]; then
  ${PROJECT_PATH}/deploy/load-git-config.sh ${LOADED}
fi