#################################################################################
# insights_event_service_spec.rb
#
# Test suite for the Azure::Armrest::Insights::EventService class.
#################################################################################
require 'spec_helper'

describe "Insights::EventService" do
  before do
    setup_params
    hash = {:x_ms_ratelimit_remaining_subscription_reads => '14999'}
    allow_any_instance_of(String).to receive(:headers).and_return(hash)
  end

  let(:ies) { Azure::Armrest::Insights::EventService.new(@conf) }

  context "inheritance" do
    it "is a subclass of ArmrestService" do
      expect(Azure::Armrest::Insights::EventService.ancestors).to include(Azure::Armrest::ArmrestService)
    end
  end

  context "constructor" do
    it "returns a ies instance as expected" do
      expect(ies).to be_kind_of(Azure::Armrest::Insights::EventService)
    end
  end

  context "instance methods" do
    it "defines a list method" do
      expect(ies).to respond_to(:list)
    end
  end

  context "paging support" do
    let(:response_bodies) do
      [
        '{"value":[{"channels":"one"}],"nextLink":"https://example.com?skipToken=123"}',
        '{"value":[{"channels":"two"},{"channels":"two"}],"nextLink":"https://example.com?skipToken=456"}',
        '{"value":[{"channels":"three"},{"channels":"three"},{"channels":"three"}]}'
      ]
    end

    it "returns a single page of results" do
      response = response_bodies.first
      allow(response).to receive(:body).and_return(response)
      allow(response).to receive(:status).and_return(200)

      expect(ies).to receive(:rest_get).and_return(response)

      event_list = ies.list

      expect(event_list.first.channels).to eq("one")
      expect(event_list.size).to eq(1)
      expect(event_list.skip_token).to eq("123")
      expect(event_list.response_headers).to eql(:x_ms_ratelimit_remaining_subscription_reads=>"14999")
    end

=begin
    # TODO: Fix this. Need to stub out get_all_results properly.
    it "returns all the pages of results" do
      response_bodies.each_with_index do |response, index|
        allow(response).to receive(:body).and_return(response_bodies[index])
        allow(response).to receive(:status).and_return(200)
      end

      expect(ies).to receive(:rest_get).and_return(*response_bodies)

      events = ies.list(:all => true)

      expect(events.first.channels).to eq("one")
      expect(events.last.channels).to eq("three")
      expect(events.skip_token).to be_nil
    end
=end
  end
end
