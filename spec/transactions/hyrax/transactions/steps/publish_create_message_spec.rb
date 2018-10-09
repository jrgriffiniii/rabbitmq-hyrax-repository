# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::Transactions::Steps::PublishCreateMessage do
  subject(:step) { described_class.new }

  let(:work) do
    GenericWork.new do |work|
      work.apply_depositor_metadata 'foo'
      work.title = ['test']
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      work.license = ['http://creativecommons.org/licenses/by/3.0/us/']
      work.save(validate: false)
    end
  end
  let(:messaging_client) { instance_double(MessagingClient) }

  before do
    Hyrax::PermissionTemplate.find_or_create_by(source_id: AdminSet.find_or_create_default_admin_set_id)
    allow(messaging_client).to receive(:publish)
    allow(MessagingClient).to receive(:new).and_return(messaging_client)
  end

  describe '#call' do
    it 'successfully publishes a message for the creation of the work' do
      expect(step.call(work, :created)).to be_success

      expect(messaging_client).to have_received(:publish).with(work, :created)
    end
  end
end
