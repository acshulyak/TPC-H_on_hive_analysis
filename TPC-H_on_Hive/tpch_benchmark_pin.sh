source benchmark.conf;
#source pin.conf;

#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/Mix/obj-intel64/mix-mt.so -i"
#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/Mix/obj-intel64/mix-mt.so -i"
#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/Mix/obj-intel64/mix-mt.so -i -o /home/ashulyak/hadoop/mix_abs_q6_wait3/mix.out"
#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/Mix/obj-intel64/mix-mt.so -i -o /home/ashulyak/hadoop/mix_abs_q6/mix.out -top_blocks 1"
#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -smc_support 1 -smc_strict 1 -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/Mix/obj-intel64/mix-mt.so -i"
#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/SimpleExamples/obj-intel64/inscount2_mt.so -i"
#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/ManualExamples/obj-intel64/follow_child_tool.so"
#PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/MemTrace/obj-intel64/insbuffer.so -emit -start_ins 10000000000 -stop_ins 11000000000 -o /home/ashulyak/hadoop/instrace_q6/instrace.out"
PIN_CMD="/home/ashulyak/pin-3.0-76991-gcc-linux/pin -pid $1 -follow_execv -t /home/ashulyak/pin-3.0-76991-gcc-linux/source/tools/MemTrace/obj-intel64/insbuffer.so -emit -num_intervals 1 -ins_interval 10000000000 -warmup_ins 10000000000 -snippet_size 350000000 -smarts -o /home/ashulyak/hadoop/instrace_q1/instrace.out"
#PIN_CMD="/home/ashulyak/pinplay-drdebug-pldi2016-3.0-pin-3.0-76991-gcc-linux/pin -pid $1 -t /home/ashulyak/pinplay-drdebug-pldi2016-3.0-pin-3.0-76991-gcc-linux/extras/pinplay/bin/intel64/pinplay-driver.so -log -log:basename /home/ashulyak/hadoop/q6-pinball_$1/q6-pinball -log:exclude:skip 10000000000 -log:mp_mode -pinplay:msgon log_mp -pinplay:max_threads 192 -log:pid"
#PIN_CMD="/home/ashulyak/pinplay-drdebug-pldi2016-3.0-pin-3.0-76991-gcc-linux/pin -pid $1 -t /home/ashulyak/pinplay-drdebug-pldi2016-3.0-pin-3.0-76991-gcc-linux/extras/pinplay/bin/intel64/pinplay-driver.so -log -log:basename /home/ashulyak/hadoop/q6-pinball_$1/q6-pinball -log:mp_mode -pinplay:msgon log_mp -pinplay:max_threads 192"


q_nums=(1 3 6 14 19)
#q_nums=(1)

if [ -e "$LOG_FILE" ]; then
  timestamp=`date "+%F-%R" --reference=$LOG_FILE`
  backupFile="$LOG_FILE.$timestamp"
  mv $LOG_FILE $LOG_DIR/$backupFile
fi

echo ""
echo "***********************************************"
echo "*           PC-H benchmark on Hive            *"
echo "***********************************************"
echo "                                               " 
echo "Running Hive from $HIVE_HOME" | tee -a $LOG_FILE
echo "Running Hadoop from $HADOOP_HOME" | tee -a $LOG_FILE
echo "See $LOG_FILE for more details of query errors."
echo ""

trial=0
while [ $trial -lt $NUM_OF_TRIALS ]; do
  trial=`expr $trial + 1`
  echo "Executing Trial #$trial of $NUM_OF_TRIALS trial(s)..."
  echo $1
  for q_num in ${q_nums[@]}; do
    query=${HIVE_TPCH_QUERIES_ALL[$(($q_num-1))]}
    echo "Running Hive query: $query" | tee -a log_results/${query}_log.txt
    $PIN_CMD
    #IOPID=$!
    $TIME_CMD $HIVE_CMD -v -f $BASE_DIR/$query 2>&1 | tee -a log_results/${query}_${1}_log.txt | grep '^Time:'
                returncode=${PIPESTATUS[0]}
    kill $1
    if [ $returncode -ne 0 ]; then
      echo "ABOVE QUERY FAILED:$returncode"
    fi
  done

done # TRIAL
echo "***********************************************"
echo ""
