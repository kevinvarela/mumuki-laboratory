class Organization < ApplicationRecord
  include Mumukit::Platform::Organization::Helpers

  serialize :profile, Mumukit::Platform::Organization::Profile
  serialize :settings, Mumukit::Platform::Organization::Settings
  serialize :theme, Mumukit::Platform::Organization::Theme

  validate :ensure_consistent_public_login

  belongs_to :book
  has_many :usages

  validates_presence_of :contact_email, :locale
  validates :name, uniqueness: true,
                   presence: true,
                   format: { with: Mumukit::Platform::Organization::Helpers.anchored_valid_name_regex }
  validates :locale, inclusion: { in: Mumukit::Platform::Locale.supported }

  after_create :reindex_usages!
  after_update :reindex_usages!, if: lambda { |user| user.saved_change_to_book_id? }

  has_many :guides, through: 'usages', source: 'item', source_type: 'Guide'
  has_many :exercises, through: :guides
  has_many :assignments, through: :exercises
  has_many :exams

  defaults do
    self.class.base.try do |base|
      self.theme         = base.theme    if theme.empty?
      self.settings      = base.settings if settings.empty?
      self.contact_email ||= base.contact_email
      self.book          ||= base.book
      self.locale        ||= base.locale
    end
  end

  def in_path?(item)
    usages.exists?(item: item) || usages.exists?(parent_item: item)
  end

  def notify_recent_assignments!(date)
    notify_assignments! assignments.where('assignments.updated_at > ?', date)
  end

  def notify_assignments_by!(submitter)
    notify_assignments! assignments.where(submitter_id: submitter.id)
  end

  def silent?
    test?
  end

  def reindex_usages!
    transaction do
      drop_usage_indices!
      book.index_usage! self
      exams.each { |exam| exam.index_usage! self }
    end
    reload
  end

  def drop_usage_indices!
    usages.destroy_all
  end

  def index_usage_of!(item, parent)
    Usage.create! organization: self, item: item, parent_item: parent
  end

  def accessible_exams_for(user)
    exams.select { |exam| exam.accessible_for?(user) }
  end

  def has_login_method?(login_method)
    self.login_methods.include? login_method.to_s
  end

  def explain_error(code, advice)
    errors_explanations.try { |it| it[code.to_s] } || I18n.t(advice)
  end

  def notify!(event = 'Changed')
    Mumukit::Nuntius.notify_event! "Organization#{event}", organization: as_platform_json
  end

  private

  def ensure_consistent_public_login
    errors.add(:base, :consistent_public_login) if settings.customized_login_methods? && public?
  end

  def notify_assignments!(assignments)
    puts "We will try to send #{assignments.count} assignments, please wait..."
    assignments.each { |assignment| assignment.notify! }
  end

  class << self
    def central
      find_by name: 'central'
    end

    def base
      find_by name: 'base'
    end
  end
end
