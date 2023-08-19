# frozen_string_literal: true

require("concurrent")

MAX_DELAY = 1.minutes
TOPIC_NAME = "topic-kisi"

namespace(:worker) do
  # if timestamp already passed or same as Time.now we will process the message
  def to_process?(timestamp)
    remaining_time = [timestamp.to_i - Time.now.to_i, 0].max
    remaining_time.zero?
  end

  # execution of job and acknowledging of message after execution
  def process_message(message, pubsub)
    puts("\n [WORKER][process_message] Time to process.")
    message.modify_ack_deadline!(MAX_DELAY.to_i)

    ActiveJob::Base.execute(JSON.parse(message.data))

    # puts("\n [WORKER][process_message] About to acknowledge message #{message.message_id}.")
    message.acknowledge!
    puts("\n [WORKER][process_message] Message #{message.message_id} was acknowledged!")
  rescue StandardError => e
    puts("\n [ERROR][WORKER][process_message]: #{e.message} #{e.backtrace}")
    enqueue_failed_jobs(message, pubsub)
  end

  # publish failed jobs to morgue queue
  # create a subscription under the failed jobs topic
  def enqueue_failed_jobs(message, pubsub)
    puts("\n [WORKER][enqueue_failed_jobs] Message: #{message.data}")

    failed_topic = "#{TOPIC_NAME}-morgue-queue"
    pubsub.topic(failed_topic).publish(JSON.dump(message.data)) # publish failed messages to morgue topic
    pubsub.subscribe(failed_topic) # create a subscription
    puts("\n [WORKER][enqueue_failed_jobs] Done publishing: #{message.data}")
  rescue StandardError => e
    puts("\n [ERROR][WORKER][enqueue_failed_jobs]: Error publishing to morgue queue : #{e.message}")
  end

  desc('Run the worker')
  task(run: :environment) do
    # See https://googleapis.dev/ruby/google-cloud-pubsub/latest/index.html

    puts("Worker starting...")

    pubsub = Pubsub.new
    subscription = pubsub.subscribe(TOPIC_NAME)

    subscriber = subscription.listen do |message|
      puts("\n Received message: #{message.data}")
      if to_process?(message.attributes['timestamp'])
        puts("\n [LISTEN] Processing right away....")
        process_message(message, pubsub)
      else
        delay = message.attributes['timestamp'].to_i - Time.now.to_i
        puts("\n [LISTEN] Will be processed after #{delay}s")
        message.modify_ack_deadline!(delay)
      end
    end
    # Propagate expection from child threads to the main thread as soon as it is
    # raised. Exceptions happened in the callback thread are collected in the
    # callback thread pool and do not propagate to the main thread
    Thread.abort_on_exception = true

    # Start background threads that will call the block passed to listen
    begin
      subscriber.start

      # Block, letting processing threads continue in the background
      sleep
      # subscriber.stop.wait!
    rescue StandardError => e
      puts("\n [ERROR][LISTEN] Exception #{e.inspect}: #{e.message}")
      raise('Stopped listening for messages.')
    end
  end

  desc('Enqueue jobs')
  task(enqueue_jobs: :environment) do
    puts('Enqueuing jobs...')
    index = 0
    timer_task = Concurrent::TimerTask.new(execution_interval: 0.2) do |task|
      puts("\n [TimerTask] Enqueue job #{index + 1}.....")
      PubsubJob.perform_later("PubSubJob - #{rand(1000)}")
      index += 1
      # task.execution_interval += 1
      if index >= 5
        puts("\n [TimerTask] Stopping task...")
        task.shutdown
      end
    rescue StandardError => e
      puts("[ERROR][TimerTask]: #{e.message} #{e.backtrace}")
      raise
    end

    timer_task.execute # blocking call - this task will stop itself

    sleep
  end
end
