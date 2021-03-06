#!usr/bin/python

import sys
from sets import Set

inFile = open(sys.argv[1], "r")
outFile = open(sys.argv[1]+".csv", "w")

test_map = {"r003c": "Unhalted Core Cycles",
            "r00c0": "Instructions Retired",
            "r4f2e": "LLC References",
            "r412e": "LLC Misses",
            "r00c4": "Branches",
            "r00c5": "Branch Misses",
            "r01a2": "Total Resource Stalls",
            "r04a2": "RS Resource Stalls",
            "r08a2": "SB Resource Stalls",
            "r10a2": "ROB Resource Stalls",
            "r012c": "Uops Retired",
            "r0280": "iL1 misses",
            "r08d1": "dL1 misses",
            "r8108": "dTLB Load Misses",
            "r0149": "dTLB Store Misses",
            "r0185": "iTLB Misses",
            "r2024": "L2 instruction misses",
            "r024c": "HW PF Hits for Loads",
            "r014c": "SW PF Hits for Loads",
            "r0110": "FP Instructions",
            "rf010": "SSE Instructions",
            "r0124": "L2 Read Hits",
            "r0324": "L2 Reads",
            "r0824": "L2 RFO Misses",
            "r0c24": "L2 RFOs",
            "r2024": "L2 Instruction Read Misses",
            "r3024": "L2 Instruction Reads",
            "r8024": "L2 Prefetch Misses",
            "rc024": "L2 Prefetches",
            "r0279": "IDQ.EMPTY",
            "r0480": "ICACHE.IFETCH_STALL",
            "rc189": "BR_MISP_EXEC.COND",
            "r8489": "BR_MISP_EXEC.INDIRECT_JMP_NON_CALL_RET",
            "r8889": "BR_MISP_EXEC.RETURN_NEAR",
            "r9089": "BR_MISP_EXEC.DIRECT_NEAR_CALL",
            "ra089": "BR_MISP_EXEC.INDIRECT_NEAR_CALL",
            "r003c": "CPU_CLK_UNHALTED.THREAD_P",
            "r019c": "IDQ_UOPS_NOT_DELIVERED.CORE"}

results = {}
events = Set()

for line in inFile:
  line = line.strip()
  if "#" not in line and len(line) > 0:
    line = line.split(" ")
    line = filter(None, line)
    event = line[2].split(":")
    if test_map.has_key(event[0]):
      event_name = test_map[event[0]]
    else:
      print event[0], "not a known event"
      event_name = event[0]
    if len(event) > 1:
        if event[1] == "u":
          event_name += "(user mode)"
        elif event[1] == "k":
          event_name += "(system mode)"
    events.add(event_name)
    if not results.has_key(float(line[0])):
      results[float(line[0])] = {}
    results[float(line[0])][event_name] = int(line[1].replace(',',''))

events = list(events)
outFile.write("time,"+",".join(events)+"\n")
order_results = sorted(results.keys())
for key in order_results:
  time_events = [str(results[key].get(event, "")) for event in events]
  outFile.write(str(key)+","+",".join(time_events)+"\n")

inFile.close()
outFile.close()

