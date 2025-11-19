# Object Tables - predates ObjectRef

CREATE OR REPLACE EXTERNAL TABLE `ai-learning-agents.unstructured_data.obj_records`
WITH CONNECTION `ai-learning-agents.us-central1.big-lake-connection`
OPTIONS(
  object_metadata = 'SIMPLE',
  uris = ['gs://image-expense-receipt-dataset/*','gs://sample-architecture-decks/*'],
  max_staleness = INTERVAL 1 DAY,
  metadata_cache_mode = 'AUTOMATIC');


-- CREATE EXTERNAL TABLE `ai-learning-agents.unstructured_data.obj_retail_receipts`
-- WITH CONNECTION `ai-learning-agents.us-central1.big-lake-connection`
-- OPTIONS(
--   object_metadata = 'SIMPLE',
--   uris = ['gs://image-retail-receipt-dataset/*'],
--   max_staleness = INTERVAL 1 DAY,
--   metadata_cache_mode = 'AUTOMATIC');



-- CREATE OR REPLACE EXTERNAL TABLE `ai-learning-agents.unstructured_invoices.obj_records`
-- WITH CONNECTION `ai-learning-agents.us-central1.big-lake-connection`
-- OPTIONS(
--   object_metadata = 'SIMPLE',
--   uris = ['gs://u2s_sample_invoices/*'],
--   max_staleness = INTERVAL 1 DAY,
--   metadata_cache_mode = 'AUTOMATIC');