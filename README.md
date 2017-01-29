#TPC-H On Hive Analysis

This project provides the tools necessary to collect a variety of performance metrics on Hive and MySQL with the TPC-H benchmark suite. These tests were done with a single-node setup in all cases. In this README, I will detail the steps necessary to recreate my experiments.

#Setup
##Dependencies
- Hive on Hadoop: Follow the instruction found at https://www.tutorialspoint.com/hive/hive_installation.htm to install Hadoop and Hive. It includes instruction to install all the dependencies necessary.
- Tez: Download tez veresion that was used in our study (0.7.1) from http://archive.apache.org/dist/tez/0.7.0/apache-tez-0.7.0-src.tar.gz or download the latest from https://tez.apache.org/releases/index.html. Uncompress the source and follow the instructions in BUILDING.txt in the root directory. By following those instructions, the file INSTALL.md will be generated. Follow those instructions as well.
- MySQL

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

#Test Metrics Setup
##Logs
##Query Plans
##I/O
##Perf
##Pin

#Run

#Process Results
