# frozen_string_literal: true

module Hyrax
  module Actors
    class MessagingActor < Hyrax::Actors::BaseActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] if publishing the created event was successful
      def create(env)
        messaging_client.publish(env.curation_concern, :created)
        next_actor.create(env)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] if publishing the updated event was successful
      def update(env)
        messaging_client.publish(env.curation_concern, :updated)
        next_actor.update(env)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] if publishing the deleted event was successful
      def destroy(env)
        messaging_client.publish(env.curation_concern, :deleted)
        next_actor.destroy(env)
      end

      private

      def messaging_client
        @messaging_client ||= MessagingClient.new(amqp_url: 'amqp://localhost:5672', exchange_name: 'my_repository')
      end
    end
  end
end
