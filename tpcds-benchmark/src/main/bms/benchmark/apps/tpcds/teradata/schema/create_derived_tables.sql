CREATE SET TABLE fact_affinity_base ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      ss_item_sk1 INTEGER,
      ss_item_sk2 INTEGER,
      observed_prob FLOAT,
      expected_prob FLOAT,
      log_lift FLOAT)
PRIMARY INDEX ( ss_item_sk1 );

CREATE SET TABLE fact_agg_item_affinity ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      ss_item_sk1 INTEGER,
      ss_item_sk2 INTEGER,
      observed_prob FLOAT,
      expected_prob FLOAT,
      log_lift FLOAT)
PRIMARY INDEX ( ss_item_sk1 );

