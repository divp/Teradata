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

CREATE SET TABLE fact_agg_sales_ledger ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      d_date DATE FORMAT 'YY/MM/DD',
      i_item_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC,
      i_brand CHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_store_id CHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC,
      s_store_name VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      transaction_count INTEGER,
      quantity INTEGER,
      wholesale_cost DECIMAL(15,2),
      net_paid DECIMAL(15,2),
      singles_promo_apparel_net_paid DECIMAL(15,2),
      family_credit_promo_apparel_net_paid DECIMAL(15,2))
PRIMARY INDEX ( d_date );

