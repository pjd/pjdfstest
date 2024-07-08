#!/bin/python3
# encoding: utf-8

###############################################################################
# 一个简单清晰的执行pjdfstest测试的脚本
# 脚本包含的功能
# 可选参数部分：
# 1. -N 参数，测试的次数，跑几轮，默认为1；重复`prove -r`的次数
# 2. -R 参数，乱序跑，random；cmd = cmd + "--shuffle"
# 3. -P 参数，并发跑，parallel，默认为1；cmd = cmd + "--jobs=1"
# 
# 结果对比
# 会给出一个 el7.9_knfsd.result的文件，里面包含了作为标杆的测试结果
# 1. 将每一轮的测试结果记录到日志文件中；
# 2. 将本轮的测试结果和标杆结果进行对比，如果有不一致的地方，输出到stdout/stderr
# 本脚本的目的，就在于 1. 高亮结果不一致的地方；2. 提供 -N -R -P 参数
# 
# prove 的输出结果示例：
# [root@node42 dir1]# prove -r /home/wenchang/pjdfstest/tests/
# /home/wenchang/pjdfstest/tests/chflags/00.t .......... ok   
# /home/wenchang/pjdfstest/tests/chflags/01.t .......... ok   
# /home/wenchang/pjdfstest/tests/chflags/02.t .......... ok   
# /home/wenchang/pjdfstest/tests/chflags/03.t .......... ok   
# /home/wenchang/pjdfstest/tests/chflags/04.t .......... ok   
# /home/wenchang/pjdfstest/tests/chmod/12.t ............ Failed 6/14 subtests 
# /home/wenchang/pjdfstest/tests/chown/00.t ............ 1239/1323 
# Test Summary Report
# -------------------
# /home/wenchang/pjdfstest/tests/chmod/12.t          (Wstat: 0 Tests: 14 Failed: 6)
#   Failed tests:  3-4, 7-8, 11-12
# 仅需要和截取 “Test Summary Report” 之上的部分
###############################################################################

import subprocess
import argparse
import difflib
import time


# ANSI颜色代码
GREEN = '\033[92m'
RED = '\033[91m'
RESET = '\033[0m'

def pre_format_output(actual_result_list):
    """
    the failed output maybe like this, result is breaked into multiple lines
    we should merge them into one line.
    And trim everything after "Test Summary Report".

    output sample: 
/home/pjdfstest/tests/chmod/02.t ............ ok
/home/wenchang/pjdfstest/tests/chmod/03.t ..
Failed 1/5 subtests

Test Summary Report
-------------------
/home/wenchang/pjdfstest/tests/chmod/03.t (Wstat: 0 Tests: 5 Failed: 1)
  Failed test:  5
Files=1, Tests=5,  1 wallclock secs ( 0.02 usr  0.00 sys +  0.18 cusr  0.13 csys =  0.33 CPU)
Result: FAIL 
    """
    formated_result = []
    i = 0

    while i < len(actual_result_list):
        if len(actual_result_list[i]) <= 1 or actual_result_list[i].startswith("Test Summary Report"):
            break
        if ("ok" in actual_result_list[i]) or ("Failed" in actual_result_list[i]):
            formated_result.append(actual_result_list[i])
            i += 1
        else:
            formated_result.append(actual_result_list[i] + actual_result_list[i+1])
            i += 2

    return formated_result


def diff_result(expected, actual):
    """
    param expected: expected result
    param actual: actual result
    diff result line by line, print to stdout
    """
    lines = len(expected)
    for i in range(lines):
        if not expected[i].startswith("/home/pjdfstest/tests/"):
            continue
        if expected[i][:-1] != actual[i]:
            print(GREEN + "Expect: '" + expected[i][:-1] + "'" + RESET)
            print(RED + "Actual: '" + actual[i] + "'" + RESET + "\n")


def run_pjdfstest(rounds=1, shuffle=False, parallel=1, expected_result="/home/pjdfstest/scripts/el7.9_knfsd.result"):
    """
    param rounds: 测试的次数, 跑几轮, 默认为1, 重复`prove -r`的次数
    param shuffle: 乱序跑, random, cmd = cmd + "--shuffle" (当前乱序不支持diff)
    param parallel: 并发跑, 默认为1, cmd = cmd + "--jobs=1"
    param expected_result: 作为标杆的测试结果, 采用标准CentOS7.9 knfsd的测试结果
    """
    base_cmd = ["prove", "-r", "/home/pjdfstest/tests/"]

    if shuffle:
        base_cmd.append("--shuffle")
    
    if parallel > 1:
        base_cmd.append("--jobs=" + str(parallel))

    with open(expected_result, "r") as f:
        expected_result = f.readlines()
    
    for i in range(rounds):
        print("Round %d" % (i+1))
        cmd = base_cmd
        print(" ".join(cmd))
        start = time.time()
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        end = time.time()
        print("Time cost: %f" % (end - start))

        # 对比结果
        actual_result = result.stdout.decode().split("\n")
        formated_result = pre_format_output(actual_result)

        # 先保存当前测试结果到 ./yymmdd_hhmmss_.result 中
        with open("./%s_%s.result" % (time.strftime("%Y%m%d_%H%M%S"), i+1), "w") as f:
            f.write("\n".join(formated_result))

        diff_result(expected_result, formated_result)



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run pjdfstest with options")
    parser.add_argument("-N", "--rounds", type=int, default=1, help="Number of rounds to run the test")
    parser.add_argument("-R", "--shuffle", action="store_true", help="Run the test in random order")
    parser.add_argument("-P", "--parallel", type=int, default=1, help="Run the test in parallel")
    parser.add_argument("-E", "--expected", type=str, default="/home/pjdfstest/scripts/el7.9_knfsd.result", help="Expected result file")
    args = parser.parse_args()
    run_pjdfstest(args.rounds, args.shuffle, args.parallel, args.expected)
