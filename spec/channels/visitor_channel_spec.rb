require "rails_helper"

RSpec.describe VisitorChannel, type: :channel do
  let(:image) { create(:image) }
  let(:user_count) { 0 }

  it "manages user count when subscribing and unsubscribing from the channel" do
    expect(REDIS).to receive(:get).with("user_count_#{image.id}").and_return( user_count)

    # Subscribe to the channel
    stub_connection
    allow(REDIS).to receive(:get).and_call_original

    subscribe(id: image.id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("visitor_channel_#{image.id}")
    expect(REDIS.get("user_count_1")).to eq user_count + 1

    # Unsubscribe from the channel
    subscription.unsubscribed
    expect(subscription).to_not have_stream_from("visitor_channel_#{image.id}")
    expect(REDIS.get("user_count_1")).to eq user_count
  end
end
