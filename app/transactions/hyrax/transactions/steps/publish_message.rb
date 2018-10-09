# frozen_string_literal: true
require "dry/transaction"
require "dry/transaction/operation"

module Hyrax
  module Transactions
    module Steps
      class PublishMessage
        include Dry::Transaction::Operation
        ##
        # @param [Hyrax::WorkBehavior] work
        # @param [Symbol] state
        #
        # @return [Dry::Monads::Result] `Failure` if there is no `AdminSet` for
        #   the input; `Success(input)`, otherwise.
        def call(work, state)
          Success(messaging_client.publish(work, state))
        rescue
          Failure(:amqp_error)
        end

        private

          def messaging_client
            @messaging_client ||= MessagingClient.new(amqp_url: 'amqp://localhost:5672', exchange_name: 'my_repository')
          end
      end
    end
  end
end
