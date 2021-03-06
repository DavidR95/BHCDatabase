class QuestionsController < ApplicationController
  def index
    @questions = Question.all
    @questions_grid = QuestionsGrid.new(params[:questions_grid]) { |scope| scope.page(params[:page]) }
  end

  def show
    @question = Question.find(params[:id])
  end

  private

  def question_params
    params.require(:question).permit(:question, :sort, :visible, :multiple_choice)
  end
end
