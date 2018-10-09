# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::Transactions::CreateWork do
  subject(:transaction) { described_class.new }

  let(:work) do
    GenericWork.new do |work|
      work.apply_depositor_metadata 'foo'
      work.title = ['test']
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      work.license = ['http://creativecommons.org/licenses/by/3.0/us/']
      work.save(validate: false)
    end
  end
  let(:xmas) { DateTime.parse('2018-12-25 11:30').iso8601 }
  let(:messaging_client) { instance_double(MessagingClient) }

  before do
    Hyrax::PermissionTemplate.find_or_create_by(source_id: AdminSet.find_or_create_default_admin_set_id)
    allow(messaging_client).to receive(:publish)
    allow(MessagingClient).to receive(:new).and_return(messaging_client)
  end

  describe '#call' do
    it 'is a success' do
      expect(transaction.call(work)).to be_success
    end

    context 'with a new work' do
      let(:work) do
        GenericWork.new do |work|
          work.title = ['test']
        end
      end

      it 'persists the work' do
        expect { transaction.call(work) }
          .to change { work.persisted? }
          .to true
      end
    end

    it 'sets visibility to restricted by default' do
       expect { transaction.call(work) }
        .not_to change { work.visibility }
        .from Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    it 'sets the default admin set' do
        expect { transaction.call(work) }
        .to change { work.admin_set&.id }
        .to AdminSet.find_or_create_default_admin_set_id
    end

    it 'sets the modified time using Hyrax::TimeService' do
        allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(xmas)
        expect { transaction.call(work) }.to change { work.date_modified }.to xmas
    end

    it 'sets the created time using Hyrax::TimeService' do
      allow(Hyrax::TimeService).to receive(:time_in_utc).and_return(xmas)
      expect { transaction.call(work) }.to change { work.date_uploaded }.to xmas
    end

    it 'successfully publishes a message for the creation of the work' do
      transaction.call(work)

      expect(messaging_client).to have_received(:publish).with(work, :created)
    end
  end
end
