#!/usr/bin/python3

import argparse
import os
import sys


DEFAULT_DISTRACTIONS = [
    "facebook.com",
    "www.facebook.com",
    "reddit.com",
    "www.reddit.com",
    "old.reddit.com",
    "news.ycombinator.com",
    "twitter.com",
    "api.twitter.com",
    "youtube.com",
    "www.youtube.com",
    "linkedin.com",
]


JFF_MANAGED = "\t#jff"
DRY_RUN = False


def get_distractions():
    fd = None
    try:
        fd = open(os.path.expanduser("~/.config/jff/distractions"))
    except OSError:
        return DEFAULT_DISTRACTIONS
    else:
        return [line.strip() for line in fd.readlines()]
    finally:
        if fd:
            fd.close()


def load_etc_hosts():
    with open("/etc/hosts") as fd:
        return [line.strip("\n") for line in fd.readlines()]


def remove_jff_hosts(etc_hosts):
    return [host_line for host_line in etc_hosts if not host_line.endswith(JFF_MANAGED)]


def disable_distracting_sites(distractions):
    return [f"127.0.0.1\t{host}\t{JFF_MANAGED}" for host in distractions]


def parse_args():
    parser = argparse.ArgumentParser(
        description="Disable/enable distracting sites",
    )
    parser.add_argument(
        "--dry",
        dest="dry_run",
        action="store_true",
        help=("don't update /etc/hosts, print to stdout instead"),
    )

    parser.add_argument("action", help="enable/disable", choices=["enable", "disable"])
    return parser.parse_args()


def write_hosts(hosts, dry_run):
    if dry_run:
        for host in hosts:
            print(host)
    else:
        with open('/etc/hosts', 'w') as etc_hosts:
            for host in hosts:
                etc_hosts.write(host + '\n')


def enable(args):
    hosts = load_etc_hosts()
    hosts = remove_jff_hosts(hosts)
    hosts += disable_distracting_sites(get_distractions())
    write_hosts(hosts, args.dry_run)


def disable(args):
    hosts = load_etc_hosts()
    hosts = remove_jff_hosts(hosts)
    write_hosts(hosts, args.dry_run)


def main():
    args = parse_args()
    if args.action == "enable":
        enable(args)
    elif args.action == "disable":
        disable(args)
    else:
        sys.stderr.write(f"bad action: {args.action}")
        sys.exit(1)


if __name__ == "__main__":
    main()
