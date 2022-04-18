#!/usr/bin/env python3

from __future__ import print_function
import sys
from os import path

from inotify import adapters, constants
import six


def wait_for_dir(watched_path):
    # watched_path = six.binary_type(watched_path.encode('utf-8'))
    i = adapters.InotifyTree(watched_path, mask=constants.IN_CLOSE_WRITE)
    for event in i.event_gen():
        if event is not None:
            filename = path.basename(event[3])
            dir_name = event[2]
            if any(
                [
                    filename.startswith(".#"),
                    filename.startswith("flycheck"),
                    filename.endswith("~"),
                    filename.startswith("./.mypy_cache/"),
                    dir_name.endswith(".cache/v/cache"),
                ]
            ):
                continue
            else:
                print(event)
                sys.exit(0)


if __name__ == "__main__":
    wait_for_dir(sys.argv[1])
