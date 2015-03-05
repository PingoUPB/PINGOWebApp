class AnswerPairController < ApplicationController
	def create
  		@question = Question.find(params[:question_id])
  		@answer_pair = @question.answer_pairs.create!(params[:answer_pair])
  		redirect_to @question, :notice => "Comentario criado!"
	end
end
