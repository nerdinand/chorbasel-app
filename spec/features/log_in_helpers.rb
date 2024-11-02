# frozen_string_literal: true

def first_login_step(user)
  visit users_sign_in_path
  fill_in 'E-Mail-Adresse',	with: user.email
  click_on 'Einloggen'
end

def match_delivered_email(regex)
  email = ActionMailer::Base.deliveries.last
  email.body.to_s.match(regex)
end

def submit_code(code)
  fill_in 'Code', with: code
  click_on 'Bestätigen'
end

def log_in_with_code(user)
  first_login_step(user)
  match = match_delivered_email(/^Benutze diesen Code um dich einzuloggen: (?<code>[A-Z\d]{6})$/)
  submit_code(match[:code])
end

def log_in_with_magic_link(user)
  first_login_step(user)
  match = match_delivered_email(
    /^Oder du kannst diesen magischen Link besuchen, um dich direkt einzuloggen:\n(?<link>.+)$/
  )
  visit(match[:link])
end
