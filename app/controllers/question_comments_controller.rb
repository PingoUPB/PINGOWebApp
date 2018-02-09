class QuestionCommentsController < ApplicationController

before_action :load_and_check_access

def create
    @comment = @question.question_comments.build(comment_params)
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @question, notice: t("messages.save_ok") }
        format.js { render partial: "questions/update_comments", locals: {comment: @comment} }
      else
        format.html { redirect_to @question, alert: t("messages.save_not_ok") }
        format.js { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
end

  def index
    respond_to do |format|
      format.html { render partial: "questions/comments", locals: {question: @question} }
      format.json { render json: @question.question_comments, status: :created }
    end
  end

protected

  def comment_params
  	params.require(:question_comment).permit(:text, :survey_id)
  end

  def load_and_check_access
    @question = Question.find(params[:question_id])
    render :plain => t("messages.no_access_to_question"), status: :forbidden and return false unless @question.can_be_accessed_by?(current_user)
    true
  end

end
