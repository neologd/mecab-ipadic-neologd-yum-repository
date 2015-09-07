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
ECHO_PREFIX='[update-gh-pages-branch]:'

PACKAGE_DIR_PATH=${BASEDIR}/../package/rpm
TMP_DIR=/var/tmp

NEOLOGD_VERSION=$1
OS_NAME=$2
OS_VERSION=$3
ARCH_NAME=$4

echo "${ECHO_PREFIX} Start."

TARGET_PART_PATH=packages/${NEOLOGD_VERSION}/${OS_NAME}/${OS_VERSION}/${ARCH_NAME}

RPM_FILE_NUM=0

function get_rpm_files_num () {
    echo "${ECHO_PREFIX} Check the number of RPM files. => ${PACKAGE_DIR_PATH}/RPMS/${ARCH_NAME}/"
    if [ -e ${PACKAGE_DIR_PATH}/RPMS/${ARCH_NAME}/ ]; then
        RPM_FILE_NUM=`ls -sl ${PACKAGE_DIR_PATH}/RPMS/${ARCH_NAME}/mecab-ipadic-neologd-2*.rpm | wc -l`
    fi
    echo ${RPM_FILE_NUM}
}

get_rpm_files_num
if [ ${RPM_FILE_NUM} -eq 1 ]; then

    TARGET_YMD=`ls -ltr ${PACKAGE_DIR_PATH}/RPMS/${ARCH_NAME}/mecab-ipadic-neologd-*.rpm | egrep -o '\-[0-9]{8}\-[0-9]{1,}\.'| egrep -o '[0-9]{8}' | head -1`''
    TARGET_YMD_RELEASE=`ls -ltr ${PACKAGE_DIR_PATH}/RPMS/${ARCH_NAME}/mecab-ipadic-neologd-*.rpm | egrep -o '\-[0-9]{8}\-[0-9]{1,}\.'| egrep -o '[0-9]{8}\-[0-9]{1,}' | head -1`
    TARGET_FILE_NAME=mecab-ipadic-neologd-${TARGET_YMD_RELEASE}.${ARCH_NAME}.rpm
    TARGET_FILE_PATH=${TARGET_PART_PATH}/${TARGET_FILE_NAME}

    echo "${ECHO_PREFIX} Create repodata files"
    if [ ! -e ${BASEDIR}/../${TARGET_PART_PATH} ]; then
        mkdir -p ${BASEDIR}/../${TARGET_PART_PATH}
    fi

    if [ ! -e ${BASEDIR}/../${TARGET_PART_PATH}/repodata ]; then
        cd ${BASEDIR}/../${TARGET_PART_PATH}
        createrepo .
        cd ${BASEDIR}/../
    fi

    echo "${ECHO_PREFIX} Put mecab-ipadic-neologd-${TARGET_YMD}*.${ARCH_NAME}.rpm to ${BASEDIR}/../../mecab-ipadic-neologd-gh-pages/${TARGET_PART_PATH}"
    cp ${PACKAGE_DIR_PATH}/RPMS/${ARCH_NAME}/mecab-ipadic-neologd-${TARGET_YMD}*.${ARCH_NAME}.rpm  ${BASEDIR}/../${TARGET_PART_PATH}

    echo "${ECHO_PREFIX} git add ${TARGET_FILE_PATH}"
    git add ${TARGET_FILE_PATH}
    git commit -m "Update RPM package on ${TARGET_YMD_RELEASE}"

    echo "${ECHO_PREFIX} git add repodata files"
    git add ${TARGET_PART_PATH}/repodata
    git commit -m "Add repo data for ${TARGET_FILE_NAME}"

#    git add RPM-GPG-KEY-NEolgod packages
#    git commit -m "Update RPM package on ${TARGET_YMD_RELEASE}"

    git push origin gh-pages

fi

echo "${ECHO_PREFIX} Finish."
