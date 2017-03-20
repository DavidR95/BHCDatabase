require 'test_helper'

class MedicalConditionTest < ActiveSupport::TestCase

  def setup
    @valid_condition = MedicalCondition.new(name: Faker::Lorem.word, description: Faker::Lorem.paragraph)
  end

  test 'should be valid' do
    assert @valid_condition.valid?
  end

  test 'name should be present' do
    @valid_condition.name = ''
    assert_not @valid_condition.valid?
  end

  test 'name cannot be too long' do
    @valid_condition.name = 'a' * 256
    assert_not @valid_condition.valid?
  end

  test 'description should be present' do
    @valid_condition.description = ''
    assert_not @valid_condition.valid?
  end

  test 'description cannot be too long' do
    @valid_condition.description = 'a' * 65537
    assert_not @valid_condition.valid?
  end

  test 'name should be unique' do
    duplicate_condition = @valid_condition.dup
    duplicate_condition.name = @valid_condition.name.upcase
    @valid_condition.save
    assert_not duplicate_condition.valid?
  end

end
