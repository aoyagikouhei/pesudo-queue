CREATE TABLE queues (
  id BIGSERIAL NOT NULL PRIMARY KEY
  ,created_at TIMESTAMPTZ NOT NULL
  ,started_at TIMESTAMPTZ
  ,data JSONB NOT NULL
);
