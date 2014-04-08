#!/usr/bin/python
import sys

prev_item_location = ''
total = ''
pattern = '00000000000'
stock_str = ''

for line in sys.stdin:
        [item_location,dt,amt] = line.rstrip().split('\t')
        if float(amt) == 0:
                stock_str = '0'
        else:
                stock_str = '1'
        if item_location ==  prev_item_location:
                total = total + stock_str
        else:
                if prev_item_location != '':
                        if pattern in total:
                                item, location = prev_item_location.strip().split(' ')
                                print location + '\t' + item
                total = stock_str
                prev_item_location = item_location
