# frozen_string_literal: true

module Hyrax
  module Transactions
    module Steps
      class PublishCreateMessage < PublishMessage
        ##
        # @param [Hyrax::WorkBehavior] work
        #
        # @return [Dry::Monads::Result] `Failure` if there is no `AdminSet` for
        #   the input; `Success(input)`, otherwise.
        def call(work)
          super(work, :created)
        end
      end
    end
  end
end
