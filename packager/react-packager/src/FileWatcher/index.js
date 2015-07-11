/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
'use strict';

const EventEmitter  = require('events').EventEmitter;
const sane = require('sane');
const Promise = require('promise');
const exec = require('child_process').exec;
const _ = require('underscore');

const MAX_WAIT_TIME = 25000;

const isWatchmanInstalled = new Promise(function(resolve) {
  exec('command -v watchman', function(err, out) {
    resolve(!err && out.length > 0);
  });
});

let inited = false;

class FileWatcher extends EventEmitter {

  constructor(rootConfigs, options) {
    if (inited) {
      throw new Error('FileWatcher can only be instantiated once');
    }
    inited = true;

    super();
    this._noWatchman = options.noWatchman;
    this._watcherByRoot = Object.create(null);

    this._loading = Promise.all(
      rootConfigs.map((rootConfig) =>
        createWatcher(rootConfig, this._noWatchman)
      )
    ).then(watchers => {
      watchers.forEach((watcher, i) => {
        this._watcherByRoot[rootConfigs[i].dir] = watcher;
        watcher.on(
          'all',
          // args = (type, filePath, root, stat)
          (...args) => this.emit('all', ...args)
        );
      });
      return watchers;
    });

    this._loading.done();
  }

  getWatchers() {
    return this._loading;
  }

  getWatcherForRoot(root) {
    return this._loading.then(() => this._watcherByRoot[root]);
  }

  isWatchman() {
    return this._noWatchman ? Promise.resolve(false) : isWatchmanInstalled;
  }

  end() {
    return this._loading.then(
      (watchers) => watchers.map(
        watcher => Promise.denodeify(watcher.close).call(watcher)
      )
    );
  }

  static createDummyWatcher() {
    const ev = new EventEmitter();
    _.extend(ev, {
      isWatchman: () => Promise.resolve(false),
      end: () => Promise.resolve(),
    });

    return ev;
  }
}

function createWatcher(rootConfig, noWatchman) {
  const shouldUseWatchman = noWatchman ?
    Promise.resolve(false) :
    isWatchmanInstalled;

  return shouldUseWatchman.then(function(useWatchman) {
    const Watcher = useWatchman ? sane.WatchmanWatcher : sane.NodeWatcher;
    const watcher = new Watcher(rootConfig.dir, {
      glob: rootConfig.globs,
      dot: false,
    });
    return waitForWatcher(watcher);
  });
}

function waitForWatcher(watcher) {
  return new Promise((resolve, reject) => {
    const rejectTimeout = setTimeout(function() {
      reject(new Error([
        'Watcher took too long to load',
        'Try running `watchman version` from your terminal',
        'https://facebook.github.io/watchman/docs/troubleshooting.html',
      ].join('\n')));
    }, MAX_WAIT_TIME);

    watcher.once('ready', function() {
      clearTimeout(rejectTimeout);
      resolve(watcher);
    });
  });
}

module.exports = FileWatcher;
