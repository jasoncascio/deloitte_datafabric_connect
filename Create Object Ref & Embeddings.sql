### Create initial tabluar data (raw_metadata)
## Assumption is that the files with filenames as below exist in a bucket
CREATE TABLE `ai-learning-agents.embeddings.raw_metadata` AS (
  WITH RAW AS (
    SELECT NULL AS subject, NULL AS filename, NULL AS actual_description, NULL AS random_description
    UNION ALL SELECT 'thanksgiving', 'Gemini_Generated_Image_kc8eh0kc8eh0kc8e.png', 'A thanksgiving scene amongst friends and family.', 'A blade of grass with a ladybug on it.'
    UNION ALL SELECT 'apple', 'Gemini_Generated_Image_3hmny3hmny3hmny3.png', 'An apple tree farm.', 'A canoe with the word "titanic" spraypainted on the side of it.'
    UNION ALL SELECT 'grape', 'Gemini_Generated_Image_byvxovbyvxovbyvx.png', 'Grape clusters on a vine in a vinyard.', 'Clusters of agricultural spherical objects'
    UNION ALL SELECT 'sweet potato', 'Gemini_Generated_Image_3nmc4h3nmc4h3nmc.png', 'A sweet potato on a cutting board.', 'A chaotic traffic holdup in Freehold NJ with a traffic cone that has been set on fire.'
    UNION ALL SELECT 'dog with ball', 'Gemini_Generated_Image_6aw6j06aw6j06aw6.png', 'A dog next to his ball.', 'A cat and a toy.'
    UNION ALL SELECT 'orange', 'Gemini_Generated_Image_dphxnddphxnddphx.png', 'An orange tree orchard.', 'A fruit.'
    UNION ALL SELECT 'bowl of golf balls', 'Gemini_Generated_Image_i6rlh0i6rlh0i6rl.png', 'A bowl filled with golf balls. Like a bowl of fruit but golf balls instead.', 'Chicken nuggets.'
    UNION ALL SELECT 'banana', 'Gemini_Generated_Image_pn7xzxpn7xzxpn7x.png', 'A banana tree in a banana farm.', 'A cow in a pasture with lots of groundhogs.'
  )
  SELECT * FROM RAW WHERE subject IS NOT NULL
)


### Create Object Ref column from metadata (assumes the files are in a bucket)
DECLARE uri_prefix STRING DEFAULT 'gs://jc_multimodal_for_bq_embeddings/';
DECLARE cnx STRING DEFAULT 'projects/ai-learning-agents/locations/us-central1/connections/big-lake-connection';

CREATE OR REPLACE TABLE `ai-learning-agents.embeddings.multimodal_data` AS (
  SELECT 
      st.*
    , OBJ.FETCH_METADATA(
        OBJ.MAKE_REF(uri_prefix || st.filename, cnx)
      ) AS objectrefcolumn
  FROM `ai-learning-agents.embeddings.raw_metadata` AS st
);


### Review what's in the multimodal table
SELECT
    JSON_VALUE(OBJ.GET_ACCESS_URL(objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url
  , *
FROM `ai-learning-agents.embeddings.multimodal_data`;


### Register Embedding Model
CREATE OR REPLACE MODEL `ai-learning-agents.embeddings.embedding_model`
REMOTE WITH CONNECTION `ai-learning-agents.us-central1.vertex-ai-for-gemini-remote-function`
OPTIONS(ENDPOINT = 'multimodalembedding@001');


### Generate Embeddings
CREATE OR REPLACE TABLE `ai-learning-agents.embeddings.image_embeddings` AS (
    SELECT
        mm.*
      , embedding_results.ml_generate_embedding_result AS image_embedding
    FROM ML.GENERATE_EMBEDDING(
          MODEL `embeddings.embedding_model`, 
          (
            SELECT
                objectrefcolumn.uri
              , OBJ.GET_ACCESS_URL(objectrefcolumn, 'r') AS content
            FROM `ai-learning-agents.embeddings.multimodal_data`
          )
        ) AS embedding_results
    LEFT JOIN `ai-learning-agents.embeddings.multimodal_data` mm ON (mm.objectrefcolumn.uri = embedding_results.uri)
);


### Create Vector Index - for 5000 rows or more
CREATE VECTOR INDEX embedding_index ON `ai-learning-agents.embeddings.image_embeddings`(image_embedding)
OPTIONS(index_type = 'IVF');


### Search Example
DECLARE search_query STRING DEFAULT 'banana';


# Embed the search_query string
WITH text_query_embedding AS (
  SELECT
      ml_generate_embedding_result AS query_embedding
    , ml_generate_embedding_status AS status
  FROM ML.GENERATE_EMBEDDING(
    MODEL `ai-learning-agents.embeddings.embedding_model`,
    (SELECT search_query AS content)
  )
)

SELECT
    distance
  , JSON_VALUE(OBJ.GET_ACCESS_URL(base.objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url
  , base.subject
FROM VECTOR_SEARCH(
      TABLE `ai-learning-agents.embeddings.image_embeddings`,
      'image_embedding',
      (SELECT query_embedding FROM text_query_embedding),
      top_k => 10,
      distance_type => 'COSINE'
  ) AS search_results 
ORDER BY distance ASC



