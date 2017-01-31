#TPC-H On Hive Analysis

This project provides the tools necessary to collect a variety of performance metrics on Hive with the TPC-H benchmark suite. These tests were done with a single-node setup in all cases. In this README, I will detail the steps necessary to recreate my experiments.

#Setup
##Dependencies
- Hive on Hadoop: Follow the instruction found at https://www.tutorialspoint.com/hive/hive_installation.htm to install Hadoop and Hive. It includes instruction to install all the dependencies necessary.
- Tez: Download tez veresion that was used in our study (0.7.1) from http://archive.apache.org/dist/tez/0.7.0/apache-tez-0.7.0-src.tar.gz or download the latest from https://tez.apache.org/releases/index.html. Uncompress the source and follow the instructions in BUILDING.txt in the root directory. By following those instructions, the file INSTALL.md will be generated. Follow those instructions as well.

##TPC-H Benchmark Suite on Hive
1. clone this repo
2. cd into the root directory
3. Build the database of <#>GB size.
  ```
  
  cd dbgen
  mkdir tables
  cd tables
  ../dbgen -s <#>
  ```
4. Move tables into respective directory in TPC-H_on_hive
  ```
  
  mv * ../../TPC-H_on_hive/data_<#>gb
  cd ../../TPC-H_on_hive/data_<#>gb
  ```
5. Ensure Hadoop's hdfs server is online
6. execute tpch_prepare_data.sh in the data\_<#>gb directory
  ```
  
  ./tpch_prepare_data.sh
  ```

#Run
To execute the TPC-H queries, first make sure Hadoop's hdfs and yarn server processes are online. Go to Hadoop's root directory and execute:
```
sbin/start-dfs.sh
sbin/start-yarn.sh
```
Go to TPC-H-Hive/TPC-H_on_hive.
If you want to execute with Hadoop's built in MapReduce engine:
```
rm -rf tpch
cp -r tpch_orig tpch
```
If you want to record the query plans for Hadoop's build in MapReduce engine (only edited for query's 1, 3, 6, 14, 19):
```
rm -rf tpch
cp -r tpch_orig_query_plan tpch
```
If you want to execute with the Tez execution engine (only edited for query's 1, 3, 6, 14, 19):
```
rm -rf tpch
cp -r tpch_tez tpch
```
If you want to record the query plans for the Tez execution engine (only edited for query's 1, 3, 6, 14, 19):
```
rm -rf tpch
cp -r tpch_tez_query_plan tpch
```
To execute all queries without analysis execute:
```
./tpch_benchmark.sh
```

Depending on what information you want to collect (log, io, perf, pin, etc.), follow one of the below instructions.
##Logs
All log files will be placed in the log_results/tpch directory. If you desire, you can rename a previous log_results/tpch directory to save the previous logs and make a new log_results/tpch directory. Open the tpch_benchmark_log.sh script. The q_nums variable includes a list of TPC-H queries that will be executed. Once you edit which queries you want to execute run the tests and collect the logs by executing
```
./tpch_benchmark_log.sh <unique_name_appended_to_logs>
```
##Query Plans
First make sure the query plan generating queries have been copied to the tpch directory as specified above in the "Run" instructions. Then follow the instructions for collecting "Logs" above. Instead of a log of the execution of the query being generated, a log of the query plan will be generated in the log_results directory.
##I/O
All io results files will be placed in the io_results/tpch directory. If you desire, you can rename a previous io_results/tpch directory to save the previous logs and make a new io_results/tpch directory. Open the tpch_benchmark_io.sh script. The q_nums variable includes a list of TPC-H queries that will be executed. Once you edit which queries you want to execute run the tests and collect the logs by executing
```
./tpch_benchmark_log.sh <unique_name_appended_to_logs>
```
##Perf
All perf results files will be placed in the perf_results/tpch directory. If you desire, you can rename a previous perf_results/tpch directory to save the previous logs and make a new perf_results/tpch directory.

Open the tpch_benchmark_io.sh script. The q_nums variable includes a list of TPC-H queries that will be executed. Edit which queries you want to execute.

Open the perf.conf configuration, which includes lists of performance monitoring counters. Select which list to use by renaming it PERF_TESTS. You can also make a custom list of PERF_TESTS. perf.conf also has an INTERVAL variable, which specifies the periodicity of collecting performance data over the course of the test, in milliseconds.

In order to collect the performance counter data on the bulk of Hive execution, perf must attach to the NodeManager process. execute ```jps``` to find the process ID of the NodeManager. Then execute
```
./tpch_benchmark_perf.sh <NodeManager-PID> <unique_name_appended_to_perf_logs>
```
##Pin
Open the tpch_benchmark_pin.sh script. The q_nums variable includes a list of TPC-H queries that will be executed. Edit which query you want to execute. It is recommended to only execute one query at a time because Hadoop processes can become unresponsive after PIN binary instrumentation, requiring a restart. The PIN_CMD includes full command line to execute to start PIN binary instrumentation. Edit the absolute paths of the directory to match the location of PIN on your own machine. Because the majority of execution spawns from the already runing Nodemanager process, the PIN_CMD is a standalone from launching the Hive query. -pid is used to attache to the NodeManager process, and -follow_execv is used so Pin is attached to all child processes. For Hive binary instrumentation, it is recommended to use thread safe Pintools only. You can use any pintool of your choosing. It is necessary to specify an absolute path for all Pintool log and output files because the default relative path is unknown. If you want to collect and instruction trace that can be used on the Runahead Prefetch simulator, please use the Pintool found at https://github.com/acshulyak/trace_gen.

In order to collect the instruction-level data on the bulk of Hive execution, pin must attach to the NodeManager process. execute ```jps``` to find the process ID of the NodeManager. Then execute
```
./tpch_benchmark_pin.sh <NodeManager-PID>
```
Depending on the Pintool of choice, and especially with the trace_gen Pintool, and large amount of data will be generated. To avoid filling up all available space on disk, monitor disk space periodically during the recording process with ```df```. If at any time you fill the need to end PIN recording short, do the following:

1. ^cmd\+C on running ./tpch_benchmark_pin.sh script (until it exits entirely), then
2. end all hadoop background processes with its ```./stop-dfs.sh``` and ```./stop-yarn.sh``` scripts
3. check for other hadoop processes still running by typing ```jps``` and kill them will ```kill -kill <PID>```
4. restart hadoop background processes
If execution sucessfully completes it is still recommended to do steps 2-4 above.

#Results Post-Processing
##IO
The run_io.sh script generated a long log file with statio printouts every second. The formate is neither user friendly, nor friendly for post-processing and excel sheets. To convert the file to a .csv, use the io_parse.py script found in the post_processing_scripts directory one leve down from the root directory.
```
cd <log-file-dir>
python < <relative-path-to-io_parse.py> <log-file>
```
##Perf
The perf script generates a long log file with performance counter metrics on a one second granularity. The format is user friendly, but not friendly for post-processing and excel sheets. To convert the file to a .csv, use the perf_parse.py script found in the post_processing_scripts directory one level down from the root directory.
```
cd <log-file-dir>
python <relative-path-to-perf_parse.py> <log-file>
```
If you generated many log files and want to convert them to .csv files all at once, use the all_parse.py script found inthe post_processing_scripts directory one level down from the root directory as shown below.
```
cd <log-file-dir>
python <relative-path-to-all_parse.py> <relative-path-to-perf_parse.py>
```
