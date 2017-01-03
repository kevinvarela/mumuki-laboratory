module WithPermissions
  extend ActiveSupport::Concern

  included do
    serialize :permissions, Mumukit::Auth::Permissions

    validates_presence_of :permissions
  end

  def student?
    mumukit_permissions.student? Organization.slug
  end

  def teacher?
    mumukit_permissions.teacher? Organization.slug
  end

  def set_permissions!(permissions)
    Mumukit::Auth::Store.set! self.uid, permissions
  end

  def mumukit_permissions
    Mumukit::Auth::Store.get self.uid
  end

  def accessible_organizations
    mumukit_permissions.accessible_organizations.map {|org| Organization.find_by(name: org)}.compact
  end

  def has_accessible_organizations?
    accessible_organizations.present?
  end

end