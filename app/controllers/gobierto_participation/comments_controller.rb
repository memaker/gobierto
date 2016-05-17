module GobiertoParticipation
  class CommentsController < GobiertoParticipation::ApplicationController
    def create
      @idea = @site.gobierto_participation_ideas.friendly.find(params[:idea_id])
      @comment = @idea.comments.new comment_params
      @comment.site = @site
      @comment.user = current_user
      if @comment.save
        track_create_comment_activity

        flash[:comment_notice] = t('controllers.gobierto_participation/comments.create.notice')

        # TODO: looks that there is a bug in rails if the previous action has an anchor
        #       and it can't be overwritten by the polymorphic_url, which is generating a
        #       valid anchor url:
        #       Redirected to http://orgiva.gobierto.dev/participacion/ideas/esta-es-mi-idea#comment-9
        redirect_to polymorphic_url(@comment.commentable, anchor: @comment.anchor)
      else
        flash.now[:comment_alert] = t('controllers.gobierto_participation/comments.create.alert')
        render @comment.commentable.model_name.collection + '/show'
      end
    end

    private

    def comment_params
      params.require(:gobierto_participation_comment).permit(:body)
    end

    def track_create_comment_activity
      @comment.create_activity :create, owner: current_user, ip: remote_ip, recipient: @comment.commentable
    end
  end
end
