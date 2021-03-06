require 'mumuki/laboratory/seed'

Mumuki::Laboratory::Seed.import_languages!

Mumuki::Laboratory::Seed.import_contents!

Organization.find_or_create_by!(name: 'base') do |org|
  org.contact_email = 'issues@mumuki.org'
  org.book = Book.find_by!(slug: 'mumuki/mumuki-libro-programacion')
  org.public = true
  org.login_methods = Mumukit::Login::Settings.login_methods
  org.locale = 'es'
end

Organization.find_or_create_by!(name: 'private') do |org|
  org.book = Book.find_by!(slug: 'mumukiproject/mumuki-libro-aprende-a-programar-recorrido-extendido')
  org.public = false
end

Organization.find_or_create_by!(name: 'central')
