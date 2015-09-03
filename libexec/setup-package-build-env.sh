#!/usr/bin/env /bash

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
ECHO_PREFIX='[setup-package-build-env]:'
TMP_DIR=/var/tmp

echo "${ECHO_PREFIX} Start."

echo "${ECHO_PREFIX} Add SSH key to ssh-agent process"
ssh-add ~/.ssh/id_rsa.mecab-ipadic-neologd

echo "${ECHO_PREFIX} Finish."
