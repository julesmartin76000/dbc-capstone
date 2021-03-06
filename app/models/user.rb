class User < ApplicationRecord
	has_secure_password

	has_many :messages
  has_many :chatrooms, through: :messages

	has_many :photos

  has_many :memberships, foreign_key: :member_id
  has_many :groups, through: :memberships
  has_many :sent_invites, class_name: 'Invite', foreign_key: :sender_id
  has_many :received_invites, class_name: 'Invite', foreign_key: :recipient_id

  has_many :requested_walks, foreign_key: :requester_id, class_name: 'Walk'
  has_many :guarded_walks, foreign_key: :guardian_id, class_name: 'Walk'

	validates :username, :email, :password_digest, { presence: :true }

  def walks
    {
      upcoming_walks: upcoming_walks,
      recent_walks:   recent_walks
    }
  end

  def upcoming_walks
    user_walks = all_walks

    upcoming_requests =
      user_walks[:requested_walks].where("walk_time > now()")
    upcoming_guards =
      user_walks[:guarded_walks].where( "walk_time > now()")

    upcoming_walks = upcoming_requests + upcoming_guards

  end

  def recent_walks
    user_walks = all_walks

    recent_requests = user_walks[:requested_walks].where( "walk_time < now()" ).last(5)
    recent_guards = user_walks[:guarded_walks].where( "walk_time < now()" ).last(5)

    recent_walks = recent_requests + recent_guards
  end

  def invited_groups
    invites = self.received_invites.where(accepted: nil)
    invites.map { |invite| invite.group_id }
  end

  def available_walks_across_groups
    walks_array = self.groups.map{ |group| group.available_walks }
    walks_array.flatten
  end
  private
    def all_walks
      walks = { requested_walks: self.requested_walks,
                guarded_walks:   self.guarded_walks }
    end
end
