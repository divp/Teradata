COMPRESSION_TYPE='NOCOMPRESS'
act -U db_superuser -w db_superuser -e <<EOF
\timing

\c adw
alter table return_transaction_line $COMPRESSION_TYPE;
alter table sales_transaction $COMPRESSION_TYPE;
alter table sales_transaction_line $COMPRESSION_TYPE;
alter table item_inventory $COMPRESSION_TYPE;
EOF

COMPRESSION_TYPE='COMPRESS LOW'
act -U db_superuser -w db_superuser -e <<EOF
\timing

\c twitter
alter table activity_stream $COMPRESSION_TYPE;
EOF

COMPRESSION_TYPE='NOCOMPRESS'
act -U db_superuser -w db_superuser -e <<EOF
\timing

\c weblogs
alter table tdcom_0424 $COMPRESSION_TYPE;
alter table tdcom_all $COMPRESSION_TYPE;
drop view if exists small_sessions2;
alter table tdcom_all_sessions300 $COMPRESSION_TYPE;
EOF

COMPRESSION_TYPE='COMPRESS LOW'
act -U db_superuser -w db_superuser -e <<EOF
\timing

\c wikipedia
alter table hourly_pv $COMPRESSION_TYPE;
EOF


