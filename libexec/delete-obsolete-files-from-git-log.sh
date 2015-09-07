#!/usr/bin/env bash

# Copyright (C) 2015 Toshinori Sato (@overlast)
#
#       https://github.com/neologd/mecab-ipadic-neologd
#
# Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu

BASEDIR=`cd $(dirname $0); pwd`
ECHO_PREFIX='[delete-obsolete-files-from-git-log]:'
TMP_DIR=/var/tmp

NEOLOGD_VERSION=$1
OS_NAME=$2
OS_VERSION=$3
ARCH_NAME=$4

echo "${ECHO_PREFIX} Start."

TARGET_PART_PATH=packages/${NEOLOGD_VERSION}/${OS_NAME}/${OS_VERSION}/${ARCH_NAME}
RPM_FILE_NUM=0

function get_rpm_files_num () {
    echo "${ECHO_PREFIX} Check the number of RPM files."
    if [ -e ${BASEDIR}/../${TARGET_PART_PATH}/ ]; then
        RPM_FILE_NUM=`ls -sl ${BASEDIR}/../${TARGET_PART_PATH}/mecab-ipadic-neologd-*.rpm | wc -l`
    fi
    echo ${RPM_FILE_NUM}
}

cd ${BASEDIR}/../
if [ -f ${BASEDIR}/../.git ]; then
    git checkout gh-pages
fi

get_rpm_files_num
WANNA_REMOVE_META_DATA=0
while [ ${RPM_FILE_NUM} -gt 0 ]
do
    TARGET_YMD=`ls -ltr ${BASEDIR}/../${TARGET_PART_PATH}/mecab-ipadic-neologd-*.rpm | egrep -o '\-[0-9]{8}\-[0-9]{1,}\.'| egrep -o '[0-9]{8}' | head -1`
    TARGET_YMD_RELEASE=`ls -ltr ${BASEDIR}/../${TARGET_PART_PATH}/mecab-ipadic-neologd-*.rpm | egrep -o '\-[0-9]{8}\-[0-9]{1,}\.'| egrep -o '[0-9]{8}\-[0-9]{1,}' | head -1`
    TARGET_FILE_NAME=mecab-ipadic-neologd-${TARGET_YMD_RELEASE}.${ARCH_NAME}.rpm
    TARGET_FILE_PATH=${TARGET_PART_PATH}/${TARGET_FILE_NAME}
    if [ ! -f ${TARGET_FILE_PATH} ]; then
        echo "${ECHO_PREFIX} ${TARGET_FILE_PATH} is not there"
        exit 1;
    fi
    ls -sl ${TARGET_FILE_PATH}

    if [ ! -e ${BASEDIR}/../../mecab-ipadic-neologd-yum-repository-back/${TARGET_PART_PATH} ]; then
        echo "${ECHO_PREFIX} Create temporary directory"
        mkdir -p ${BASEDIR}/../../mecab-ipadic-neologd-yum-repository-back/${TARGET_PART_PATH}
    fi

    echo "${ECHO_PREFIX} Copy files to temporary directory to backup static files"
    if [ -e  ${BASEDIR}/../../mecab-ipadic-neologd-yum-repository/${TARGET_PART_PATH}/ ]; then
        cp -rf ${BASEDIR}/../../mecab-ipadic-neologd-yum-repository/${TARGET_PART_PATH}/*.rpm   ${BASEDIR}/../../mecab-ipadic-neologd-yum-repository-back/${TARGET_PART_PATH}
    fi

    if [ -e ${TARGET_FILE_PATH} ]; then
        echo "${ECHO_PREFIX} git rm ${TARGET_FILE_PATH}"
        git rm ${TARGET_FILE_PATH}
    fi

    echo "${ECHO_PREFIX} git commit"
    git commit -m "Remove obsolete file : ${TARGET_FILE_PATH}"
    echo "${ECHO_PREFIX} git push"
#    git push origin gh-pages

    echo "${ECHO_PREFIX} delete ${TARGET_FILE_PATH} from log"
    git filter-branch -f --tree-filter "rm -f ${TARGET_FILE_PATH}"

    git gc --aggressive --prune=now

    echo "${ECHO_PREFIX} git push --force"
    git push --force origin gh-pages

    WANNA_REMOVE_META_DATA=1
    get_rpm_files_num
done

if [ ${WANNA_REMOVE_META_DATA} -eq 1 ]; then
    echo "${ECHO_PREFIX} Remove metadata of RPM files"

    REPO_FILE_NAME_ARR=(`ls -1 ${TARGET_PART_PATH}/repodata/`)
    for REPO_FILE_NAME in ${REPO_FILE_NAME_ARR[@]}
    do
        REPO_FILE_PATH=${TARGET_PART_PATH}/repodata/${REPO_FILE_NAME}
        echo ${REPO_FILE_PATH}
        if [ -e ${REPO_FILE_PATH} ]; then
            echo "${ECHO_PREFIX} git rm ${REPO_FILE_PATH}"
            git rm ${REPO_FILE_PATH}
        fi
    done

    echo "${ECHO_PREFIX} git commit"
    git commit -m "Remove obsolete files"
    echo "${ECHO_PREFIX} git push"
#    git push origin gh-pages

    for REPO_FILE_NAME in ${REPO_FILE_NAME_ARR[@]}
    do
        REPO_FILE_PATH=${TARGET_PART_PATH}/repodata/${REPO_FILE_NAME}
        echo "${ECHO_PREFIX} delete ${REPO_FILE_PATH} from log"
        git filter-branch -f --tree-filter "rm -f ${REPO_FILE_PATH}"
    done
    git filter-branch -f --tree-filter "rm -f -r ${TARGET_PART_PATH}/repodata"

    git gc --aggressive --prune=now

    echo "${ECHO_PREFIX} git push --force"
    git push --force origin gh-pages
fi

echo "${ECHO_PREFIX} Finish."
