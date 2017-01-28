#!/usr/bin/env bash

# set up configurations
source benchmark.conf;
source perf.conf;
q_nums=(1 3 6 14 19)
#q_nums=(3)
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
	I=0
  for p_test in ${PERF_TESTS[@]}; do
    echo "Running Hive query: $query with ${PERF_TESTS[$I]}" | tee -a $LOG_FILE
    PERF_T_N=$(echo ${PERF_TESTS[$I]} | sed 's/\:/\\\:/g')
    PERF_T_N=$(echo $PERF_T_N | sed 's/,/-/g')
    PERF_T_N=$(echo $PERF_T_N | sed 's/\//-/g')
    PERF_T_N=${PERF_T_N:0:30}
    echo $PERF_T_N
    for q_num in ${q_nums[@]}; do
      echo $(($q_num-1))
      query=${HIVE_TPCH_QUERIES_ALL[$(($q_num-1))]}
      #$TIME_CMD $HIVE_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE | grep '^Time:'
      #$PERF_CMD -- $HIVE_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE

      $PERF_CMD -p $1 -e ${PERF_TESTS[$I]} -o "$PERF_DIR/${query}_perf_${2}_${PERF_T_N}" -- $HIVE_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE | grep '^Time:'
      #$PERF_CMD -e ${PERF_TESTS[$I]} -o "$PERF_DIR/${query}_perflocal_${PERF_T_N}" -- $HIVE_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE | grep '^Time:'
      #echo "$PERF_CMD -a -e ${PERF_TESTS[$I]} -o \"$PERF_DIR/${query}_perf_${PERF_T_N}\" -- $HIVE_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE | grep '^Time:'"
      #$PERF_CMD -a -e ${PERF_TESTS[$I]} -o "$PERF_DIR/${query}_perf_${PERF_T_N}" -- $HIVE_CMD -f $BASE_DIR/$query 2>&1 | tee -a $LOG_FILE | grep '^Time:'
    done
                returncode=${PIPESTATUS[0]}
		if [ $returncode -ne 0 ]; then
			echo "ABOVE QUERY FAILED:$returncode"
		fi
    I=$I+1
	done

done # TRIAL
echo "***********************************************"
echo ""
