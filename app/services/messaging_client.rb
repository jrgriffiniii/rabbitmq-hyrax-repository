# frozen_string_literal: true

class MessagingClient
  def initialize(amqp_url:, exchange_name:)
    @amqp_url = amqp_url
    @exchange_name = exchange_name
  end

  def publish(model, state)
    message = generate_message(model, state)
    exchange.publish(message.as_json, persistent: true)
  rescue StandardError
    Rails.logger.warn "Unable to publish message to #{@amqp_url}"
  end

  private

  def generate_message(model, state)
    {
      model: model.as_json,
      state: state.to_s
    }
  end

  def bunny_client
    @bunny_client ||= Bunny.new(@amqp_url).tap(&:start)
  end

  def channel
    @channel ||= bunny_client.create_channel
  end

  def exchange
    @exchange ||= channel.fanout(@exchange_name, durable: true)
  end
end
