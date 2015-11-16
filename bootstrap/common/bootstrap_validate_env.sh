#!/bin/bash
#
# Copyright 2015, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

NEEDED_PROGRAMS=( curl git rsync ssh )
FAILED=0
for binary in ${NEEDED_PROGRAMS[@]}; do
  if ! which $binary >/dev/null; then
    FAILED=1
    echo "Unable to locate $binary on the path." >&2
  fi
done

if [[ $FAILED != 0 ]]; then
  echo "Please see above error output to determine which programs you need to install or make available on your path. Aborting." >&2
  exit 1
fi
