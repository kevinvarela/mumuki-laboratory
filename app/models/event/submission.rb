class Event::Submission < Event::Base
  def initialize(assignment)
    @assignment = assignment
  end

  def queue_name
    'submissions'
  end

  def as_json(options={})
    @assignment.
      as_json(except: [:exercise_id, :submission_id, :id, :submitter_id, :solution, :created_at, :updated_at],
              include: {
                guide: {only: [:slug, :name],
                  include: {
                    chapter: {only: [:id, :name]},
                    lesson: {only: [:number]},
                    language: {only: [:name]}}},
                exercise: {only: [:id, :name, :number]},
                submitter: {only: [:name, :email, :image_url], methods: [:social_id]}}).
      merge('id' => @assignment.submission_id,
            'created_at' => @assignment.updated_at,
            'content' => @assignment.solution,
            'tenant' => Book.current.name)
  end
end
