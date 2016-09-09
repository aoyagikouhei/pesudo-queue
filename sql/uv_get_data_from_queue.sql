DROP TYPE IF EXISTS type_uv_get_data_from_queue CASCADE;
CREATE TYPE type_uv_get_data_from_queue AS (
  queue_id BIGINT
  ,data JSONB
);

CREATE OR REPLACE FUNCTION uv_get_data_from_queue(
  p_multiple_count BIGINT DEFAULT NULL
) RETURNS SETOF type_uv_get_data_from_queue AS $FUNCTION$
DECLARE
  -- 適度に散らばせる
  w_offset INT := (random() * COALESCE(p_multiple_count, 5))::INT + 1;
  w_record RECORD;
BEGIN
  LOOP
    -- 開始されていないデータを取得する
    SELECT
      t1.id
      ,t1.data
    INTO
      w_record
    FROM
      queues AS t1
    WHERE
      t1.started_at IS NULL
    OFFSET
      w_offset
    LIMIT
      1
    ;

    -- レコードが無かれば、オフセットが0なら終了
    -- オフセットが0以外の場合はもう一度チェック
    IF NOT FOUND THEN
      IF 0 = w_offset THEN
        EXIT;
      ELSE
        w_offset := 0;
        CONTINUE;
      END IF;
    END IF;

    -- 更新
    UPDATE queues SET
      started_at = NOW()
    WHERE
      id = w_record.id
      AND started_at IS NULL
    ;

    -- 更新できたら終了
    IF FOUND THEN
      RETURN QUERY SELECT
        w_record.id
        ,w_record.data
      ;
      EXIT;
    END IF;
    w_offset := 0;
  END LOOP;
END;
$FUNCTION$ LANGUAGE plpgsql;
