# frozen_string_literal: true

require 'rails_helper'

describe MessagingClient do
  subject(:messaging_client) { described_class.new(amqp_url: amqp_url, exchange_name: exchange_name) }

  let(:amqp_url) { 'amqp://localhost:5672' }
  let(:exchange_name) { 'test_repository' }

  describe '#publish' do
    let(:model) { GenericWork.new }
    let(:bunny_exchange) { instance_double(Bunny::Exchange) }
    let(:bunny_channel) { instance_double(Bunny::Channel) }
    let(:bunny_session) { instance_double(Bunny::Session) }

    before do
      allow(bunny_exchange).to receive(:publish)
      allow(bunny_channel).to receive(:fanout).and_return(bunny_exchange)
      allow(bunny_session).to receive(:create_channel).and_return(bunny_channel)
      allow(bunny_session).to receive(:tap).and_return(bunny_session)
      allow(Bunny).to receive(:new).and_return(bunny_session)

      messaging_client.publish(model, :created)
    end

    it 'publishes a message encapsulating an event to the AMQP exchange' do
      expect(bunny_exchange).to have_received(:publish).with({ 'model' => model.as_json, 'state' => 'created' }, persistent: true)
    end
  end
end
