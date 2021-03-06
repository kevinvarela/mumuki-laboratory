module ExerciseInputHelper
  def render_exercise_input_layout(exercise)
    render "layouts/exercise_inputs/layouts/#{exercise.layout}"
  end

  def render_exercise_input_form(exercise)
    render "layouts/exercise_inputs/forms/#{exercise.class.name.underscore}_form"
  end

  def render_exercise_input_editor(form, exercise)
    render "layouts/exercise_inputs/editors/#{exercise.editor}", form: form, exercise: exercise
  end

  def should_render_problem_tabs?(exercise, user)
      !exercise.hidden? && (exercise.queriable? || exercise.extra_visible? || exercise.has_messages_for?(user))
  end

  def should_render_message_input?(exercise, organization = Organization.current)
    exercise.is_a?(Problem) && !exercise.hidden? && organization.raise_hand_enabled?
  end

  def render_submit_button(exercise)
    options = submit_button_options(exercise)
    %Q{<#{options.tag} for="#{options.for}"
                       class="btn btn-success btn-block btn-submit #{options.classes}"
                       data-waiting="#{t(options.waiting_t)}">
          #{fa_icon options.fa_icon, text: t(options.t)}
       </#{options.tag}>}.html_safe
  end

  def submit_button_options(exercise)
    if exercise.upload?
      struct for: 'upload-input',
             tag: :label,
             waiting_t: :uploading_solution,
             fa_icon: :upload,
             t: :upload_solution
    elsif exercise.hidden?
      struct tag: :button,
             classes: 'submission_control',
             waiting_t: :working,
             fa_icon: :play,
             t: :continue_exercise
    else
      struct tag: :button,
             classes: 'submission_control',
             waiting_t: :sending_solution,
             fa_icon: :play,
             t: :create_submission
    end
  end
end
