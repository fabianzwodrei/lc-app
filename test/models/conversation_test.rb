require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  test "test avoiding duplicates of private conversations" do
  	c1 = Conversation.create({private: true , member1_id: 2, member2_id: 4})
  	c2 = Conversation.new({private: true , member1_id: 2, member2_id: 4})
    assert c2.invalid?
  end

  test "test avoiding duplicates of private conversations - even when member-ids are swapped" do
  	c1 = Conversation.create({private: true , member1_id: 2, member2_id: 4})
  	c2 = Conversation.new({private: true , member1_id: 4, member2_id: 2})
    assert c2.invalid?
  end
end
