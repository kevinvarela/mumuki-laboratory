class ExerciseSolutionsController < ApplicationController
  include NestedInExercise

  before_action :authenticate!

  def create
    guide_previously_done = @exercise.guide_done_for?(current_user)
    @solution = @exercise.submit_solution(current_user, solution_params)
    @solution.run!
    guide_finished_by_solution = !guide_previously_done && @exercise.guide_done_for?(current_user)
    render partial: 'exercise_solutions/results', locals: {assignment: @solution.assignment, guide_finished_by_solution: guide_finished_by_solution}
  end

  private

  def solution_params
    params.require(:solution).permit(:content)
  end
end
