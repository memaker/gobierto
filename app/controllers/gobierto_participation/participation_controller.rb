module GobiertoParticipation
  class ParticipationController < GobiertoParticipation::ApplicationController

    def index
      @ideas = @site.gobierto_participation_ideas.sorted.includes(:user).limit(5)
      @consultations = @site.gobierto_participation_consultations.sorted.includes(:user).limit(5)
    end

  end
end
