#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Program to run page rank multiple times."""
import os


def page_rank():
    """Call page rank script in pig."""
    os.system('pig -x local -f twitter_account_rank_iteration.pig')


if __name__ == "__main__":
    ITERATIONS = int(raw_input('Number of iterations: '))
    while ITERATIONS > 0:
        print 'Iteration' + str(ITERATIONS)
        page_rank()
        ITERATIONS = ITERATIONS - 1
