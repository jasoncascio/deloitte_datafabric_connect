-- Note: Connection service account will need vertex ai user permission.

CREATE OR REPLACE MODEL `ai-learning-agents.unstructured_data.gemini-2_0-flash` 
REMOTE WITH CONNECTION `ai-learning-agents.us-central1.vertex-ai-for-gemini-remote-function` 
OPTIONS (endpoint = 'gemini-2.0-flash')