class QuestionCommentsController < ApplicationController

before_filter :check_access

def create
    @question = Question.find(params[:question_id])
    @comment = @question.question_comments.build(comment_params)
    
    check_access
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
    @question = Question.find(params[:question_id])
    check_access
    respond_to do |format|
      format.html { render partial: "questions/comments", locals: {question: @question} }
      format.json { render json: @question.question_comments, status: :created }
    end
  end

protected

  def comment_params
  	params.require(:question_comment).permit(:text, :survey_id)
  end

  def check_access
    render :text => t("messages.no_access_to_question"), status: :forbidden and return false if !@question.nil? && !current_user.admin && @question.user != current_user
    true
  end

end
