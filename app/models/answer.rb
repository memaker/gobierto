class Answer < ActiveRecord::Base
  QUESTION_2_ANSWERS = ['Poco', 'Apropiado', 'Mucho']

  def self.percentages_for_question(question_id)
    total = Answer.where(question_id: question_id).count
    groups = where(question_id: question_id).select('id, answer_text').group_by do |a|
      a.answer_text
    end

    Hash[groups.map do |answer_text, list|
      [answer_text, ((list.length.to_f * 100.0) / total).round(1)]
    end]
  end
end
