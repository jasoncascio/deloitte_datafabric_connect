SELECT
    uri
  , content_type
  , JSON_VALUE(OBJ.GET_ACCESS_URL(objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url

FROM `ai-learning-agents.structured_data_output.dining_expense_extraction` 
WHERE

  AI.GENERATE_BOOL(('Is the bill in this image greater than 100? ', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
  connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
  endpoint => 'gemini-2.0-flash').result
  
LIMIT 10;



SELECT
    uri
  , content_type
  , JSON_VALUE(OBJ.GET_ACCESS_URL(objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url

  , AI.GENERATE(
    ('Get address of the biller and then find the population of the city of the address in the format of "population (as of year)"', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
    connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
    endpoint => 'gemini-2.0-flash',
    output_schema => 'address STRING, population STRING',
    model_params => JSON '{"tools": [{"googleSearch": {}}]}'
    ) AS extraction_result

FROM `ai-learning-agents.structured_data_output.dining_expense_extraction` 
WHERE

  AI.GENERATE_BOOL(('Is the bill in this image greater than 100? ', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
  connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
  endpoint => 'gemini-2.0-flash').result
  
LIMIT 10;

























-- SELECT
--     uri
--   , content_type
--   , JSON_VALUE(OBJ.GET_ACCESS_URL(objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url
--   , AI.GENERATE(
--     ('Extract the name of the biller with no additional commentary', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
--       connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
--       endpoint => 'gemini-2.0-flash').result
--   , AI.GENERATE(
--     ('Extract the name of the biller with no additional commentary', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
--       connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
--       endpoint => 'gemini-2.0-flash',
--       output_schema => 'total_tax STRING, bill_total STRING').total_tax
-- FROM `ai-learning-agents.structured_data_output.dining_expense_extraction` 
-- WHERE
--   AI.GENERATE_BOOL(('Is the bill in this image greater than 100? ', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
--   connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
--   endpoint => 'gemini-2.0-flash').result
-- AND uri IN ('gs://image-expense-receipt-dataset/1133-receipt.jpg', 'gs://image-expense-receipt-dataset/1089-receipt.jpg', 'gs://image-expense-receipt-dataset/1086-receipt.jpg')
-- LIMIT 3;

-- SELECT
--     uri
--   , content_type
--   , JSON_VALUE(generated_result, '$.bill_subtotal') AS bill_subtotal
--   , JSON_VALUE(generated_result, '$.bill_total') AS bill_total
--   , JSON_VALUE(OBJ.GET_ACCESS_URL(objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url
--   -- , generated_result
--   , AI.GENERATE(
--     ('Extract the bill total ', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
--       connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
--       endpoint => 'gemini-2.0-flash').result
-- FROM `ai-learning-agents.structured_data_output.dining_expense_extraction` 
-- WHERE
--   AI.GENERATE_BOOL(('Is the bill in this image greater than 100? ', OBJ.GET_ACCESS_URL(objectrefcolumn, 'r')),
--   connection_id => 'us-central1.vertex-ai-for-gemini-remote-function',
--   endpoint => 'gemini-2.0-flash').result
-- LIMIT 1;







-- SELECT * FROM `ai-learning-agents.structured_data_output.dining_expense_extraction` 


-- SELECT
--     JSON_VALUE(generated_result, '$.bill_subtotal') AS bill_subtotal
--   , JSON_VALUE(generated_result, '$.bill_total') AS bill_total
--   , JSON_VALUE(OBJ.GET_ACCESS_URL(objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url
--   -- , generated_result
--   , *
-- FROM `ai-learning-agents.structured_data_output.dining_expense_extraction` 
-- WHERE 1=1
-- AND (CAST(JSON_VALUE(generated_result, '$.bill_subtotal') AS NUMERIC) > 100 OR CAST(JSON_VALUE(generated_result, '$.bill_total') AS NUMERIC) > 100)
-- LIMIT 1000;



-- SELECT
--     JSON_VALUE(generated_result, '$.bill_subtotal') AS bill_subtotal
--   , JSON_VALUE(generated_result, '$.bill_total') AS bill_total
--   -- , JSON_VALUE(OBJ.GET_ACCESS_URL(objectrefcolumn, 'r', INTERVAL 45 MINUTE), '$.access_urls.read_url') AS read_url
--   , *
-- FROM `ai-learning-agents.structured_data_output.dining_expense_extraction` 
-- WHERE CAST(JSON_VALUE(generated_result, '$.bill_total') AS NUMERIC) > 100
-- LIMIT 1000;
