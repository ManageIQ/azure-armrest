#################################################################################
# insights_event_service_spec.rb
#
# Test suite for the Azure::Armrest::Insights::EventService class.
#################################################################################
require 'spec_helper'

describe "Insights::EventService" do
  before { setup_params }
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
      response = double()
      expect(response).to receive(:body) { response_bodies.first }

      expect(ies).to receive(:rest_get).and_return(response)

      event_list = ies.list

      expect(event_list.first.channels).to eq("one")
      expect(event_list.size).to eq(1)
      expect(event_list.skip_token).to eq("123")
    end

    it "returns all the pages of results" do
      responses = [double(), double(), double()]
      responses.each_with_index do |response, index|
        expect(response).to receive(:body) { response_bodies[index] }
      end

      expect(ies).to receive(:rest_get).and_return(*responses)

      events = ies.list(:all => true)

      expect(events.first.channels).to eq("one")
      expect(events.last.channels).to eq("three")
    end
  end
end
