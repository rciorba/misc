#!python
import sys
from os import path

from inotify import adapters, constants


def wait_for_dir(watched_path):
    i = adapters.InotifyTree(watched_path, mask=constants.IN_CLOSE_WRITE)
    for event in i.event_gen():
        if event is not None:
            filename = path.basename(event[3])
            if filename.startswith('.#') or filename.startswith('flycheck') or filename.endswith("~"):
                continue
            else:
                print event
                sys.exit(0)


if __name__ == '__main__':
    wait_for_dir(sys.argv[1])
