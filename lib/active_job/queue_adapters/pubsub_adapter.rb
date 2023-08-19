# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    class PubsubAdapter
      # Enqueue a job to be performed.
      #
      # @param [ActiveJob::Base] job The job to be performed.
      def enqueue(job)
        ActiveSupport::Notifications.instrument("enqueue.pubsub_adapter") do
          # puts("\n [PubsubAdapter][enqueue]: #{job.inspect}")
          publish_job(job)
        end
      end

      # Enqueue a job to be performed at a certain time.
      #
      # @param [ActiveJob::Base] job The job to be performed.
      # @param [Float] timestamp The time to perform the job.
      def enqueue_at(job, timestamp)
        ActiveSupport::Notifications.instrument("enqueue_at.pubsub_adapter") do
          # puts("\n [PubsubAdapter][enqueue_at]: #{job.inspect} timestamp: #{timestamp}")
          publish_job(job, timestamp)
        end
      end

      private

      # push job to the topic
      def publish_job(job, timestamp = 0)
        ActiveSupport::Notifications.instrument("publish_job.pubsub_adapter") do
          # puts("\n [PubsubAdapter][publish_job]: #{job.inspect}")
          serialized_job = job.serialize
          Pubsub.new.topic(job.queue_name).publish(JSON.dump(serialized_job), { timestamp: timestamp })
        end
      rescue StandardError => e
        puts("[ERROR][PubsubAdapter] Received error while publishing: #{e.message}")
      end
    end
  end
end
