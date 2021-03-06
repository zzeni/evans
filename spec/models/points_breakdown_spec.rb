require 'spec_helper'

describe PointsBreakdown do
  let(:user) { FactoryGirl.create :user }

  it "can tell whether a user has starred posts" do
    user = FactoryGirl.create :user
    breakdown = PointsBreakdown.new user

    breakdown.should_not be_having_starred_posts

    topic = FactoryGirl.create :topic, :user => user, :starred => true
    breakdown.should be_having_starred_posts
  end

  it "can iterate all starred posts a user has" do
    topic = FactoryGirl.create :topic, :user => user, :starred => true
    reply = FactoryGirl.create :reply, :user => user, :starred => true

    breakdown = PointsBreakdown.new user

    breakdown.enum_for(:each_starred_post_with_title).to_a.map(&:first).should =~ [topic, reply]
  end

  it "yields the topic title when iterating topics" do
    FactoryGirl.create :topic, :user => user, :starred => true, :title => 'Topic'

    breakdown = PointsBreakdown.new user

    breakdown.enum_for(:each_starred_post_with_title).to_a.map(&:second).should =~ ['Topic']
  end

  it "yields the title of the reply's topic when iterating replies" do
    topic = FactoryGirl.create :topic, :title => 'Topic with replies'
    FactoryGirl.create :reply, :user => user, :topic => topic, :starred => true

    breakdown = PointsBreakdown.new user

    breakdown.enum_for(:each_starred_post_with_title).to_a.map(&:second).should =~ ['Topic with replies']
  end
end
