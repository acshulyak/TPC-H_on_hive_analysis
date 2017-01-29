#TPC-H On Hive Analysis

This project provides the tools necessary to collect a variety of performance metrics on Hive and MySQL with the TPC-H benchmark suite. These tests were done with a single-node setup in all cases. In this README, I will detail the steps necessary to recreate my experiments.

#Setup
##Dependencies
- Hive on Hadoop: Follow the instruction found at https://www.tutorialspoint.com/hive/hive_installation.htm to install Hadoop and Hive. It includes instruction to install all the dependencies necessary.
- Tez: Download tez veresion that was used in our study (0.7.1) from http://archive.apache.org/dist/tez/0.7.0/apache-tez-0.7.0-src.tar.gz or download the latest from https://tez.apache.org/releases/index.html. Uncompress the source and follow the instructions in BUILDING.txt in the root directory. By following those instructions, the file INSTALL.md will be generated. Follow those instructions as well.

##TPC-H Benchmark Suite on Hive
1. clone this repo

  ```
  git clone 
  ```
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
If you want to execute with the Tez execution engine (only edited for query's 1, 3, 6, 14, 19):
```
rm -rf tpch
cp -r tpch_tez tpch
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

