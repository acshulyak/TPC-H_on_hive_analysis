source benchmark.conf;

#q_nums=(1 3 6 14 19)
q_nums=(1 6 14 19)
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

	for q_num in ${q_nums[@]}; do
    query=${HIVE_TPCH_QUERIES_ALL[$(($q_num-1))]}
    echo "Running Hive query: $query" | tee -a $LOG_FILE
   
    iostat -t 1 > io_results/${query}_${1}_io &
    IOPID=$!
    $TIME_CMD $HIVE_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE | grep '^Time:'
                returncode=${PIPESTATUS[0]}
    kill $IOPID
    if [ $returncode -ne 0 ]; then
      echo "ABOVE QUERY FAILED:$returncode"
    fi
  done

done # TRIAL
echo "***********************************************"
echo ""
