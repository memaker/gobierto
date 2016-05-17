module GobiertoParticipation
  class ConsultationsController < GobiertoParticipation::ApplicationController
    before_action :admin_user, only: [:new, :create, :edit, :update, :destroy]
    before_action :load_consultation, only: [:show, :edit, :update, :destroy]


    # TODO: add pagination
    def index
      @consultations = @site.gobierto_participation_consultations.sorted.includes(:user)

      admin_add_link new_gobierto_participation_consultation_path
    end

    def show
      @answer = @consultation.answers.new

      admin_add_link new_gobierto_participation_consultation_path
      admin_edit_link edit_gobierto_participation_consultation_path(@consultation)
      admin_remove_link gobierto_participation_consultation_path(@consultation)
    end

    def new
      @consultation = current_user.consultations.new kind: 'open_answers'
    end

    def create
      @consultation = current_user.consultations.new consultation_params
      @consultation.site = @site

      if @consultation.save
        track_create_consultation_activity

        redirect_to @consultation, notice: t('controllers.gobierto_participation/consultations.create.notice')
      else
        flash.now[:alert] = t('controllers.gobierto_participation/consultations.create.alert')
        render 'new'
      end
    end

    def edit
      admin_add_link new_gobierto_participation_consultation_path
      admin_remove_link gobierto_participation_consultation_path(@consultation)
    end

    def update
      if @consultation.update_attributes consultation_params
        track_update_consultation_activity

        redirect_to @consultation, notice: t('controllers.gobierto_participation/consultations.update.notice')
      else
        flash.now[:alert] = t('controllers.gobierto_participation/consultations.update.alert')
        render 'edit'
      end
    end

    def destroy
      @consultation.destroy
      track_destroy_consultation_activity

      redirect_to gobierto_participation_consultations_path, notice: t('controllers.gobierto_participation/consultations.destroy.notice')
    end

    private

    def consultation_params
      params.require(:gobierto_participation_consultation).permit(:title, :body, :open_until_date, :open_until_time, :kind,
                                                               options_attributes: [:id, :option, :_destroy])
    end

    def load_consultation
      @consultation = @site.gobierto_participation_consultations.friendly.find params[:id]
    end

    def track_create_consultation_activity
      @consultation.create_activity :create, owner: current_user, ip: remote_ip
    end

    def track_update_consultation_activity
      @consultation.create_activity :update, owner: current_user, ip: remote_ip, parameters: { changes: @consultation.previous_changes.except(:updated_at) }
    end

    def track_destroy_consultation_activity
      @consultation.create_activity :destroy, owner: current_user, ip: remote_ip, parameters: { title: @consultation.title }
    end

  end
end
