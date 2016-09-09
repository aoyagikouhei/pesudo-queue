INSERT INTO queues (created_at, data) 
SELECT
  NOW()
  ,'{}'
FROM
  generate_series(1, 10000)
;
