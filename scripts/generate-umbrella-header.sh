#!/bin/bash

set -e

SCRIPTS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(dirname $SCRIPTS)

LIBRARY_NAME="React"
UMBRELLA_HEADER_PATH="${ROOT}/React/${LIBRARY_NAME}.h"

cd $ROOT

LIBRARY_HEADERS="\
$(find React/Base -name "*.h")

$(find React/Executors -name "*.h")

React/Modules/RCTExceptionsManager.h
React/Modules/RCTUIManager.h

React/Views/RCTAnimationType.h
React/Views/RCTAutoInsetsProtocol.h
React/Views/RCTConvert+CoreLocation.h
React/Views/RCTConvert+MapKit.h
React/Views/RCTPointerEvents.h
React/Views/RCTScrollableProtocol.h
React/Views/RCTShadowView.h
React/Views/RCTView.h
React/Views/RCTViewControllerProtocol.h
React/Views/RCTViewManager.h
React/Views/RCTViewNodeProtocol.h
React/Views/UIView+React.h\
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
  awk -v lib="${LIBRARY_NAME}" '{if (NF) print "#import <"lib"/"$0">"; else print;}'
 )\
" > "${UMBRELLA_HEADER_PATH}"
