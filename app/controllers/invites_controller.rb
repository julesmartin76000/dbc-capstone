class InvitesController < ApplicationController
  def index
  end

  def create
    @invite = Invite.new(invite_params)
    @invite.sender_id = current_user.id

    if @invite.save
      # Send an email to the address in recipient_email
      if @invite.recipient
        InviteMailer.invite_existing_user(@invite).deliver_now
      else
        # Send the "you're invited to join SafeWalk email"
        InviteMailer.invite_new_user(@invite).deliver_now
      end
      flash[:notice] = "#{@invite.recipient_email} was successfully invited."
      render @invite.group
    else
      flash[:notice] = { error: ["Sorry, but your invitation didn't go through"] }
      redirect_to @invite.group
    end
  end

# Defining the update route for invites will allow someone to accept membership
# to a group. Using recipient instead of current_user should keep multiple
# people from joining a group through a single invitation.
  def update
    @invite = Invite.find(params[:id])

    @invite.accepted = params[:accepted]
    @invite.save

    if @invite.accepted == true
      flash[:notice] = ["You're a member now"]
      @invite.recipient.groups << @invite.group
      redirect_to @invite.group
    else
      flash[:notice] = ["You can request to join later if you change your mind"]
      redirect_to '/'
    end
  end

  private
    def invite_params
      params.require(:invite).permit(:recipient_email, :group_id)
    end

end
