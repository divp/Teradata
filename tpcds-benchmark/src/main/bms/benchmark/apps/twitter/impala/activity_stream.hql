CREATE TABLE IF NOT EXISTS activity_stream2 (
    record_type_id INT,
    document_id BIGINT,
    posted_ts STRING,
    posted_hour INT,
    posted_day INT,
    posted_week INT,
    posted_month INT,
    posted_year INT,
    doc_txt STRING,
    doc_txt_reg STRING,
    is_retweet BOOLEAN,
    user_id BIGINT,
    user_name STRING,
    screen_name STRING,
    follower_count INT,
    friends_count INT,
    user_location STRING,
    in_reply_to_status_id BIGINT,
    language STRING,
    klout_score INT,
    polarity STRING,
    polarity_score DOUBLE,
    topic STRING,
    topic_score DOUBLE)
PARTITIONED BY (posted_dt STRING)
STORED AS SequenceFile;

SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET hive.exec.max.dynamic.partitions=500;
SET hive.exec.max.dynamic.partitions.pernode=500;
SET mapred.child.java.opts=-Xmx2048m ;
SET mapred.reduce.tasks=40 ;
SET hive.mapred.reduce.tasks.speculative.execution=false ;

SET hive.exec.compress.output=true;
SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
SET mapred.output.compression.type=BLOCK;

INSERT OVERWRITE TABLE activity_stream2 PARTITION (posted_dt)
    SELECT
        record_type_id,
        document_id,
        posted_ts,
        posted_hour,
        posted_day,
        posted_week,
        posted_month,
        posted_year,
        doc_txt,
        doc_txt_reg,
        is_retweet,
        user_id,
        user_name,
        screen_name,
        follower_count,
        friends_count,
        user_location,
        in_reply_to_status_id,
        language,
        klout_score,
        polarity,
        polarity_score,
        topic,
        topic_score,
        posted_dt
  FROM activity_stream
DISTRIBUTE BY posted_dt;

