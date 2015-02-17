#!/usr/bin/env bash

set -e

SCRIPTS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(dirname $SCRIPTS)

LIBRARY_NAME="React"
UMBRELLA_HEADER_PATH="${ROOT}/React/${LIBRARY_NAME}.h"

cd $ROOT

LIBRARY_HEADERS="\
$(find React/Base -name "*.h" -exec basename {} \;)

$(find React/Executors -name "*.h" -exec basename {} \;)

RCTExceptionsManager.h
RCTUIManager.h

RCTAnimationType.h
RCTAutoInsetsProtocol.h
RCTConvert+CoreLocation.h
RCTConvert+MapKit.h
RCTPointerEvents.h
RCTScrollableProtocol.h
RCTShadowView.h
RCTView.h
RCTViewControllerProtocol.h
RCTViewManager.h
RCTViewNodeProtocol.h
UIView+React.h\
"

echo \
"/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

$(
  echo "${LIBRARY_HEADERS}" |
  awk -v lib="${LIBRARY_NAME}" '{if (NF) print "#import \""$0"\""; else print;}'
 )\
" > "${UMBRELLA_HEADER_PATH}"
