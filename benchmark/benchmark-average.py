#!/usr/bin/python3

import sys
import glob
import statistics

def get_boottime(logfile):
    with open(logfile) as fin:
        line = fin.read()
        tokens = line.split()
        return int(tokens[6])

def print_concise(boottimes):
    bt_avg = statistics.mean(boottimes)
    print("On average, {}ms".format(bt_avg))

def print_full(boottimes):
    print('{} record[s]'.format(len(boottimes)))

    if len(boottimes) == 1:
        print('  val: {}'.format(boottimes[0]))
    else:
        bt_max = max(boottimes)
        bt_min = min(boottimes)
        bt_avg = statistics.mean(boottimes)
        bt_std = statistics.stdev(boottimes)
        print('  min: {}'.format(bt_min))
        print('  max: {}'.format(bt_max))
        print('  avg: {}'.format(bt_avg))
        print('  std: {}'.format(bt_std))

def main():
    if len(sys.argv) < 2:
        print('Usage: {} <glob-format> [full]')
        return 1

    full = False
    if len(sys.argv) > 2 and sys.argv[2] == 'full':
        full = True

    pattern = sys.argv[1]
    boottimes = [get_boottime(logfile) for logfile in glob.glob(pattern)]
    if not boottimes:
        print('No records found')
        return 1

    if full:
        print_full(boottimes)
    else:
        print_concise(boottimes)


if __name__ == '__main__':
    sys.exit(main())
