# The Kisi Backend Code Challenge (Sky's Version)

This repository contains:
- A bare-bones Rails 6 API app with a `Gemfile` that contains the neccessary libraries for the project.
- A configured adapter ([lib/active_job/queue_adapters/pubsub_adapter.rb](lib/active_job/queue_adapters/pubsub_adapter.rb)) to enqueue jobs. 
- A rake task ([lib/tasks/worker.rake](lib/tasks/worker.rake)) to launch the worker process.
- A class ([lib/pubsub.rb](lib/pubsub.rb)) that wraps the GCP Pub/Sub client. 
- A [Dockerfile](Dockerfile) and a [docker-compose.yml](docker-compose.yml) configured to spin up necessary services (web server, worker, pub/sub emulator).

To start run `bundle install`.

To run the worker use the command:
`GOOGLE_APPLICATION_CREDENTIALS=credentials.json rails worker:run`

To run the rake task to enqueue 5 sample jobs:
`GOOGLE_APPLICATION_CREDENTIALS=credentials.json rails worker:enqueue_jobs`

Make sure that the `credentials.json` file contains valid google pubsub credentials that will allow you access to your project.

Changes made by the developer:
1. Implement PubsubAdapter and register the ActiveJob queue adapter in `application.rb`
2. Implement rake task to dequeue and execute pending jobs by pulling the messages from Google Cloud Pubsub.
3. Create a morgue queue topic and publish failed jobs after trying at most 2 times and waiting for 5 minutes apart.
4. For the subscriptions, the developer enabled the `enable_exactly_once_delivery` which means the message cannot be redelivered once it has been successfully acknowledged.
5. Create a rake task to enqueue jobs to the topic (at least five jobs per second).
```

If you run docker with a VM (e.g. Docker Desktop for Mac) we recommend you allocate at least 2GB Memory
