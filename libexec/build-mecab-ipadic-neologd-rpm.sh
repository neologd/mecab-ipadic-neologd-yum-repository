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
ECHO_PREFIX="[build-mecab-ipadic-neologd-rpm]"

NEOLOGD_VERSION="v0.0.2"

NEOLOGD_VERSION=$1
OS_NAME=$2
OS_VERSION=$3
ARCH_NAME=$4

PACKAGE_DIR_PATH=${BASEDIR}/../package/rpm
TMP_DIR=/var/tmp

echo "${ECHO_PREFIX} Start..."

echo "$ECHO_PREFIX Check the existance of libraries"
COMMANDS=(mecab-config)
for COMMAND in ${COMMANDS[@]};do
    if [ ! `which ${COMMAND}` ]; then
        echo "$ECHO_PREFIX ${COMMAND} is not found."
        exit 1
    else
        echo "$ECHO_PREFIX     ${COMMAND} => ok"
    fi
done

if [ -e ${PACKAGE_DIR_PATH} ]; then
    echo "${ECHO_PREFIX} ${PACKAGE_DIR_PATH} is already there"
else
    echo "${ECHO_PREFIX} mkdir -p ${PACKAGE_DIR_PATH}"
    mkdir -p ${PACKAGE_DIR_PATH}
fi

if [ -e ${PACKAGE_DIR_PATH}/BUILD ]; then
    echo "${ECHO_PREFIX} Sub directories of RPM files are already there"
    rm -rf ${PACKAGE_DIR_PATH}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}/*
else
    echo "${ECHO_PREFIX} mkdir sub directories of RPM files"
    mkdir -p ${PACKAGE_DIR_PATH}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
fi
PACKAGE_SOURCES_DIR_PATH=${PACKAGE_DIR_PATH}/SOURCES
PACKAGE_SPECS_DIR_PATH=${PACKAGE_DIR_PATH}/SPECS
YMD=`ls -ltr \`find ${BASEDIR}/../../mecab-ipadic-neologd/build\` | grep mecab-ipadic-2.7.0-20070801-neologd | egrep -o '[0-9]{8}' | tail -1`
NEOLOGD_BUILD_DIR_NAME=mecab-ipadic-2.7.0-20070801-neologd-${YMD}
NEOLOGD_BUILD_DIR_PATH=${BASEDIR}/../../mecab-ipadic-neologd/build/${NEOLOGD_BUILD_DIR_NAME}
if [ ! -e ${NEOLOGD_BUILD_DIR_PATH} ]; then
    echo "${ECHO_PREFIX} Error => ${NEOLOGD_BUILD_DIR_PATH} is not found"
    echo "${ECHO_PREFIX} You should try to install mecab-ipadic-NEologd first !!"
    exit 1
else
    echo "${ECHO_PREFIX} ${NEOLOGD_BUILD_DIR_PATH} is found"
fi

NEOLOGD_DIR_NAME=mecab-ipadic-neologd-${YMD}
NEOLOGD_DIR_PATH=${TMP_DIR}/${NEOLOGD_DIR_NAME}
if [ -e ${NEOLOGD_DIR_PATH} ]; then
    echo "${ECHO_PREFIX} Cleaning system dictionary package directory"
    rm -rf ${NEOLOGD_DIR_PATH}
fi

echo "${ECHO_PREFIX} Compressing recent build directory"
NEOLOGD_ARCHIVE_FILE_NAME=${NEOLOGD_DIR_NAME}.tar.gz
NEOLOGD_ARCHIVE_FILE_PATH=${TMP_DIR}/${NEOLOGD_ARCHIVE_FILE_NAME}
cp -rf ${NEOLOGD_BUILD_DIR_PATH} ${NEOLOGD_DIR_PATH}
echo "\\n" >> ${NEOLOGD_DIR_PATH}/COPYING
cat ${BASEDIR}/../../mecab-ipadic-neologd/COPYING >> ${NEOLOGD_DIR_PATH}/COPYING
cd ${TMP_DIR}
tar zcvf ${NEOLOGD_ARCHIVE_FILE_PATH} ${NEOLOGD_DIR_NAME}

SOURCE_NEOLOGD_ARCHIVE_FILE=${PACKAGE_SOURCES_DIR_PATH}/${NEOLOGD_ARCHIVE_FILE_NAME}
echo "${ECHO_PREFIX} Setting system dictionary package"
if [ -e ${SOURCE_NEOLOGD_ARCHIVE_FILE} ]; then
    rm ${SOURCE_NEOLOGD_ARCHIVE_FILE}
fi
cp ${NEOLOGD_ARCHIVE_FILE_PATH} ${PACKAGE_SOURCES_DIR_PATH}

SPEC_FILE_PATH=${PACKAGE_SPECS_DIR_PATH}/mecab-ipadic-neologd-${YMD}.spec
echo "${ECHO_PREFIX} Generate spec file of ${NEOLOGD_DIR_NAME}"
perl ${BASEDIR}/../libexec/generate-spec-file-of-mecab-ipadic-neologd.pl ${NEOLOGD_DIR_NAME} ${YMD} ${NEOLOGD_VERSION} > ${SPEC_FILE_PATH}

echo "${ECHO_PREFIX} Build RPM package based on ${SPEC_FILE_PATH}"
cd ${NEOLOGD_DIR_PATH}

rpmbuild -v -ba --define="dist .el6" ${SPEC_FILE_PATH}

echo "${ECHO_PREFIX} Cleaning ${TMP_DIR}"
rm -rf ${NEOLOGD_DIR_PATH}
rm -rf ${NEOLOGD_ARCHIVE_FILE_PATH}

echo "${ECHO_PREFIX} Add signature to RPM file"
echo "${ECHO_PREFIX} Please prompt the pass phrase of PGP key"
rpm --addsign ${PACKAGE_DIR_PATH}/RPMS/${ARCH_NAME}/mecab-ipadic-neologd-${YMD}*.${ARCH_NAME}.rpm

echo "${ECHO_PREFIX} Finish !!"
