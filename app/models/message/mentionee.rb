module Message::Mentionee
  extend ActiveSupport::Concern

  def mentionees
    users = room.users.where(id: mentioned_users.map(&:id))

    if body_contains_room_mention?
      users = users.or(room.users.where.not(id: creator_id))
    end

    users.distinct
  end

  private
    def mentioned_users
      if body.body
        body.body.attachables.grep(User).uniq
      else
        []
      end
    end

    def body_contains_room_mention?
      return false unless body.body?
      body.body.to_plain_text.include?("@room")
    end
end
