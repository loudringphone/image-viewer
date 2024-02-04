require "rails_helper"

RSpec.describe VisitorChannel, type: :channel do
  let(:image) { create(:image) }
  let(:user_count) { 0 }

  before do
    stub_connection
    allow(REDIS).to receive(:get).with("user_count_#{image.id}").and_return({ user_count: user_count }.to_json)
  end

  it "subscribes to a stream when room id is provided" do
    subscribe(id: image.id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("visitor_channel_#{image.id}")
  end
end