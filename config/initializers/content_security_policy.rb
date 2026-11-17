# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
# Allow @vite/client to hot reload javascript changes in development
#    policy.script_src *policy.script_src, :unsafe_eval,
#      "http://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

# You may need to enable this in production as well depending on your setup.
#    policy.script_src *policy.script_src, :blob if Rails.env.test?

#     policy.style_src   :self, :https
# Allow @vite/client to hot reload style changes in development
#    policy.style_src *policy.style_src, :unsafe_inline if Rails.env.development?

#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

Rails.application.configure do
  config.content_security_policy do |policy|
    # Allow 'unsafe-eval' for WASM modules (Emscripten uses eval/Function)
    # Allow 'unsafe-inline' for verovio WASM bundle which contains inline scripts
    policy.script_src :self, :https, "'unsafe-eval'", "'unsafe-inline'"

    # Allow @vite/client and scripts served by the Vite dev server
    if Rails.env.development?
      policy.script_src(
        *policy.script_src, "http://#{ViteRuby.config.host_with_port}"
      )
    end

    # Allow WASM execution
    policy.wasm_unsafe_eval true if policy.respond_to?(:wasm_unsafe_eval)
  end
end
