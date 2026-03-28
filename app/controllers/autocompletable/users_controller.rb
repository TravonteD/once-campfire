class Autocompletable::UsersController < ApplicationController
  def index
    users = find_autocompletable_users.with_attached_avatar.ordered
    results = page_and_extract_portion(users, per_page: 20)

    results.unshift(*room_mention_item) if room_mention_item.present?

    render json: results
  end

  private
    def find_autocompletable_users
      params[:query].present? ? users_scope.active.filtered_by(params[:query]) : users_scope.active
    end

    def users_scope
      params[:room_id].present? ? Current.user.rooms.find(params[:room_id]).users : User.all
    end

    def room_mention_item
      return @room_mention_item if defined?(@room_mention_item)

      if params[:room_id].present? && params[:query].blank?
        @room_mention_item = [
          { id: "room", name: "room", type: "room_mention", avatar_url: "" }
        ]
      else
        @room_mention_item = []
      end
    end
end
