module GobiertoParticipation
  class ConsultationAnswersController < GobiertoParticipation::ApplicationController
    before_action :logged_in_user, only: [:create]

    def create
      @consultation = GobiertoParticipation::Consultation.friendly.find(params[:consultation_id])
      @answer = @consultation.answers.new answer_params
      @answer.user = current_user
      @answer.site = @site
      if @answer.save
        track_create_answer_activity

        redirect_to @consultation, notice: t('controllers.gobierto_participation/consultation_answers.create.notice')
      else
        flash.now[:alert] = t('controllers.gobierto_participation/consultation_answers.create.alert')
        render @consultation.model_name.collection + '/show'
      end
    end

    private

    def answer_params
      params.require(:gobierto_participation_consultation_answer).permit(:answer, :comment, :consultation_option_id)
    end

    def track_create_answer_activity
      @answer.create_activity :create, owner: current_user, ip: remote_ip, recipient: @consultation
    end

  end
end
