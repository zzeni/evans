require 'spec_helper'

describe Solution do
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:task_id) }
  it { should validate_presence_of(:code) }
  it { Factory(:solution).should validate_uniqueness_of(:user_id).scoped_to(:task_id) }

  it { should belong_to(:user) }
  it { should belong_to(:task) }
  it { should have_many(:comments) }

  it "can find all the solutions for task" do
    task = FactoryGirl.create :task
    solution = FactoryGirl.create :solution, :task => task

    Solution.for_task(task.id).should == [solution]
  end

  it "can find the number of rows in the code" do
    Solution.new(:code => 'print("baba")').rows.should == 1
    Solution.new(:code => "1\n2").rows.should == 2
    Solution.new(:code => "1\n2\n3").rows.should == 3
  end

  describe "looking up the code of an existing solution" do
    let(:user) { FactoryGirl.create :user }
    let(:task) { FactoryGirl.create :task }

    it "retuns the code as a string" do
      FactoryGirl.create :solution, :user => user, :task => task, :code => 'code'
      Solution.code_for(user, task).should == 'code'
    end

    it "returns nil if the no solution submitted by this user" do
      Solution.code_for(user, task).should be_nil
    end
  end

  describe "commenting" do
    context "when task is open" do
      let(:solution) { build :solution, task: build(:open_task) }

      it "is available to its author" do
        solution.should be_commentable_by solution.user
      end

      it "is available to admins" do
        solution.should be_commentable_by build(:admin)
      end

      it "is not available to other users" do
        solution.should_not be_commentable_by build(:user)
      end

      it "is not available to unauthenticated people" do
        solution.should_not be_commentable_by nil
      end
    end

    context "when task is closed" do
      let(:solution) { build :solution, task: build(:closed_task) }

      it "is available to all users" do
        solution.should be_commentable_by solution.user
        solution.should be_commentable_by build(:admin)
        solution.should be_commentable_by build(:user)
      end

      it "is not available to unauthenticated people" do
        solution.should_not be_commentable_by nil
      end
    end
  end

  describe "(calculating points)" do
    [
      [18, 0, 6],
      [17, 1, 6],
      [16, 2, 5],
      [12, 6, 4],
    ].each do |passed, failed, points|
      it "has #{points} points for #{passed} passed and #{failed} failed tests" do
        FactoryGirl.build(:solution, passed_tests: passed, failed_tests: failed).points.should eq points
      end
    end

    it "has 0 points if not checked" do
      FactoryGirl.build(:solution).points.should eq 0
    end

    it "delegates max_points to task" do
      solution = FactoryGirl.build(:solution, passed_tests: 10, failed_tests: 0)

      solution.max_points.should eq Task::MAX_POINTS
    end

    it "allows non-default max points to be set" do
      solution = FactoryGirl.build(:solution, passed_tests: 10, failed_tests: 0)
      solution.task.max_points = 8

      solution.points.should eq 8
    end

    it "applies the adjustment to the points" do
      FactoryGirl.build(:solution, passed_tests: 6, failed_tests: 0, adjustment: 3).points.should eq 9
      FactoryGirl.build(:solution, passed_tests: 6, failed_tests: 0, adjustment: -2).points.should eq 4
      FactoryGirl.build(:solution, passed_tests: 1, failed_tests: 5, adjustment: -2).points.should eq 0
    end
  end
end
