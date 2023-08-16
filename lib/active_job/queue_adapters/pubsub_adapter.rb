# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    class PubsubAdapter
      # Enqueue a job to be performed.
      #
      # @param [ActiveJob::Base] job The job to be performed.
      def enqueue(job)
        puts("\n [PubsubAdapter][enqueue]: #{job.inspect}")
        publish_job(job)
      end

      # Enqueue a job to be performed at a certain time.
      #
      # @param [ActiveJob::Base] job The job to be performed.
      # @param [Float] timestamp The time to perform the job.
      def enqueue_at(job, timestamp)
        puts("\n [PubsubAdapter][enqueue_at]: #{job.inspect} timestamp: #{timestamp}")
        publish_job(job, timestamp)
      end

       # push job to the topic
      def publish_job(job, timestamp = 0)
        puts("\n [PubsubAdapter][publish_job]: #{job.inspect}")
        serialized_job = job.serialize
        Pubsub.new.topic(topic_name).publish(JSON.dump(serialized_job), { timestamp: timestamp })
      rescue StandardError => e
        puts("[ERROR][PubsubAdapter] Received error while publishing: #{e.message}")
      end

      private

      def topic_name
        @topic_name ||= Rails.application.topic_name
      end
    end
  end
end
