Generally speaking, when bringing any Vertex AI capabilities to BQ, you will need to create a resource connection
Resource connections will have their own service account
Grant that service account access to vertex products

When trying to work with ObjectRef, you will need to create (or reuse) some resource connection that has permissions to work with the bucket your files are in.

* Create resource connection (to bucket) https://docs.cloud.google.com/bigquery/docs/create-cloud-resource-connection
