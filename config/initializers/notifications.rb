# frozen_string_literal: true

ActiveSupport::Notifications.subscribe("perform.active_job") do |name, started, finished, _unique_id, _data|
  logger(name, started, finished)
end

ActiveSupport::Notifications.subscribe("enqueue.active_job") do |name, started, finished, _unique_id, _data|
  logger(name, started, finished)
end

ActiveSupport::Notifications.subscribe("enqueue_at.active_job") do |name, started, finished, _unique_id, _data|
  logger(name, started, finished)
end

ActiveSupport::Notifications.subscribe("publish_job.pubsub_adapter") do |name, started, finished, _unique_id, _data|
  logger(name, started, finished)
end

def logger(name, started, finished)
  puts("\n [NOTIF-SUBSCRIBE][#{name}] Received! (started: #{started}, finished: #{finished})")
end
