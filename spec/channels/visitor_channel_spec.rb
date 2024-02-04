require "rails_helper"

RSpec.describe VisitorChannel, type: :channel do
  let(:image) { create(:image) }
  let(:user_count) { 0 }

  it "subscribes to a stream when room id is provided" do
    expect(REDIS).to receive(:get).with("user_count_#{image.id}").and_return({ user_count: }.to_json)

    stub_connection
    allow(REDIS).to receive(:get).and_call_original

    subscribe(id: image.id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("visitor_channel_#{image.id}")
    expect(REDIS.get("user_count_1")).to eq "{\"user_count\":#{ user_count + 1 }}"
  end
end
