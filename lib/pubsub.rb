# frozen_string_literal: true

require("google/cloud/pubsub")
require("json")

class Pubsub

  def initialize; end

  # Find or create a topic.
  #
  # @param topic [String] The name of the topic to find or create
  # @return [Google::Cloud::PubSub::Topic]
  def topic(name)
    puts("\n [PubsubAdapter][topic]: #{name}")
    client.topic(name) || client.create_topic(name)
  end

  # find or create new subsription
  # @param name [String] The name of the topic to subscribe
  # we prefix the subscription name to avoid confusion
  def subscribe(name)
    puts("\n [PubsubAdapter][subscribe]: #{name}")
    prefixed_name = "subscription-#{name}"

    topic(name).subscription(prefixed_name) || topic(name).subscribe(prefixed_name, enable_exactly_once_delivery: true)
  end

  private

  # Create a new client.
  #
  # @return [Google::Cloud::PubSub]
  def client
    @client ||= Google::Cloud::PubSub.new #(project_id: "code-challenge")
  end
end
