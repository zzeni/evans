require 'spec_helper'

describe Announcement do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  it "paginates announcements in reverse chronological order" do
    second = FactoryGirl.create :announcement, :created_at => 2.days.ago
    first  = FactoryGirl.create :announcement, :created_at => 1.day.ago

    Announcement.stub :per_page => 1

    Announcement.page(1).should == [first]
    Announcement.page(2).should == [second]
  end

  it "retuns the latest announcements" do
    second = FactoryGirl.create :announcement, :created_at => 2.days.ago
    first  = FactoryGirl.create :announcement, :created_at => 1.day.ago

    Announcement.latest(1).should eq [first]
  end
end
