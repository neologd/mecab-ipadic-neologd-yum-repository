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
ECHO_PREFIX='[update-RHEL-6-package]:'
TMP_DIR=/var/tmp

echo "${ECHO_PREFIX} Start."

echo "${ECHO_PREFIX} Update seed data"
#${BASEDIR}/../../mecab-ipadic-neologd/libexec/copy-dict-seed.sh /home/overlast/git/neologd-seed-maker

echo "${ECHO_PREFIX} Create building directory of mecab-ipadic-NEologd"
#${BASEDIR}/../../mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd --prefix ${TMP_DIR}/mecab-ipadic-neologd-rhel-6 --asuser --forceyes

echo "${ECHO_PREFIX} Move to working directory"
cd ${BASEDIR}/../../mecab-ipadic-neologd-yum-repository

echo "${ECHO_PREFIX} Switch current branch to gh-pages"
#git checkout gh-pages

echo "${ECHO_PREFIX} Get recent update information"
#git pull origin gh-pages

RELEASE_VERSION=0
OS_NAME=redhat
OS_VERSION=6
ARCH_NAME=x86_64

echo "${ECHO_PREFIX} Build RPM package"
#${BASEDIR}/../libexec/build-mecab-ipadic-neologd-rpm.sh ${RELEASE_VERSION} ${OS_NAME} ${OS_VERSION} ${ARCH_NAME}

echo "${ECHO_PREFIX} Delete old gh-pages branch"
#${BASEDIR}/../libexec/delete-obsolete-files-from-git-log.sh ${RELEASE_VERSION} ${OS_NAME} ${OS_VERSION} ${ARCH_NAME}

echo "${ECHO_PREFIX} Create new gh-pages branch"
${BASEDIR}/../libexec/update-gh-pages-branch.sh ${RELEASE_VERSION} ${OS_NAME} ${OS_VERSION} ${ARCH_NAME}

echo "${ECHO_PREFIX} Finish."
