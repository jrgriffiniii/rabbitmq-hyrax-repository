# frozen_string_literal: true

require 'rails_helper'

describe Hyrax::Actors::MessagingActor do
  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:work) do
    GenericWork.new do |work|
      work.apply_depositor_metadata 'foo'
      work.title = ['test']
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      work.license = ['http://creativecommons.org/licenses/by/3.0/us/']
      work.save(validate: false)
    end
  end
  let(:ability) { instance_double(Ability) }
  let(:attributes) { {} }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
  let(:messaging_client) { instance_double(MessagingClient) }

  before do
    allow(messaging_client).to receive(:publish)
    allow(MessagingClient).to receive(:new).and_return(messaging_client)
  end

  describe '#create' do
    before do
      middleware.create(env)
    end

    it 'publishes a created message for the Work' do
      expect(messaging_client).to have_received(:publish).with(work, :created)
    end
  end

  describe '#update' do
    before do
      middleware.update(env)
    end

    it 'publishes an updated message for the Work' do
      expect(messaging_client).to have_received(:publish).with(work, :updated)
    end
  end

  describe '#destroy' do
    before do
      middleware.destroy(env)
    end

    it 'publishes a deleted message for the Work' do
      expect(messaging_client).to have_received(:publish).with(work, :deleted)
    end
  end
end
