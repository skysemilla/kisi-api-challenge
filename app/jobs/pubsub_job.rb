# frozen_string_literal: true

class PubsubJob < ApplicationJob
  retry_on(StandardError, wait: 5.minute, attempts: 2)

  def perform(*args)
    # puts("\n [PubsubJob][perform-start] #{args}")
    sleeping_time = rand(5)
    puts("\n [PubsubJob][sleeping_time]: #{sleeping_time} => #{(sleeping_time % 2).zero?}")
    raise(StandardError) if (sleeping_time % 2).zero?

    sleep(sleeping_time)
    # puts("\n [PubsubJob][perform-end] #{args}")
  end
end
