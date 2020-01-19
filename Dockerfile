FROM hasura/graphql-engine:v1.0.0

# Run Hasura
CMD graphql-engine \
    --database-url $DATABASE_URL \
    serve