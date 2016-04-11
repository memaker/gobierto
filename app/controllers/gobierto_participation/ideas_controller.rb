module GobiertoParticipation
  class IdeasController < GobiertoParticipation::ApplicationController
    before_action :logged_in_user, only: [:new, :create]
    before_action :admin_user, only: [:edit, :update, :destroy]
    before_action :load_idea, only: [:edit, :update, :destroy]

    # TODO: add pagination
    def index
      @ideas = GobiertoParticipation::Idea.sorted.includes(:user)
    end

    def show
      @idea = GobiertoParticipation::Idea.friendly.find(params[:id])
      @comment = @idea.comments.new

      admin_edit_link edit_gobierto_participation_idea_path(@idea)
      admin_remove_link gobierto_participation_idea_path(@idea)
    end

    def new
      @idea = GobiertoParticipation::Idea.new
    end

    def create
      @idea = current_user.ideas.new idea_params
      @idea.site = @site
      if @idea.save
        track_create_idea_activity

        redirect_to @idea, notice: t('controllers.gobierto_participation/ideas.create.notice')
      else
        flash.now[:alert] = t('controllers.gobierto_participation/ideas.create.alert')
        render 'new'
      end
    end

    def edit
      admin_remove_link gobierto_participation_idea_path(@idea)
    end

    def update
      if @idea.update_attributes(idea_params)
        track_update_idea_activity

        redirect_to @idea, notice: t('controllers.gobierto_participation/ideas.update.notice')
      else
        flash.now[:alert] = t('controllers.gobierto_participation/ideas.update.alert')
        render 'edit'
      end
    end

    def destroy
      @idea.destroy
      track_destroy_idea_activity

      redirect_to gobierto_participation_ideas_path, notice: t('controllers.gobierto_participation/ideas.destroy.notice')
    end

    private

    def idea_params
      params.require(:gobierto_participation_idea).permit(:title, :body)
    end

    def load_idea
      @idea = GobiertoParticipation::Idea.friendly.find(params[:id])
    end

    def track_create_idea_activity
      @idea.create_activity :create, owner: current_user, ip: remote_ip
    end

    def track_update_idea_activity
      @idea.create_activity :update, owner: current_user, ip: remote_ip, parameters: { changes: @idea.previous_changes.except(:updated_at) }
    end

    def track_destroy_idea_activity
      @idea.create_activity :destroy, owner: current_user, ip: remote_ip, parameters: { title: @idea.title }
    end

  end
end
