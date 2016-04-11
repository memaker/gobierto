module GobiertoParticipation
  class ParticipationController < GobiertoParticipation::ApplicationController

    def index
      @ideas = GobiertoParticipation::Idea.sorted.includes(:user).limit(5)
      @consultations = GobiertoParticipation::Consultation.sorted.includes(:user).limit(5)
    end

  end
end
