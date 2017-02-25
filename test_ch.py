#!/usr/bin/python3

import subprocess, sys

test_case_file = 'test_cases.txt'
with open(test_case_file, 'r', encoding='UTF-8') as f:
    next(f)    #skip first line
    test_count = 0
    for line in f:
        test_count += 1
        cmd = './' + line[2:-1]

        cmp_str = ''
        for nline in f:
            if nline == '======TEST CASE======\n':
                break
            cmp_str += nline
        
        cmd_op = subprocess.getoutput(cmd)
        if not cmd_op == cmp_str[:-1]:
            sys.exit('Mismatch for: ' + cmd)

print('No. of test cases checked:', test_count)
