# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'chartkick', to: 'chartkick.js'
pin 'Chart.bundle', to: 'Chart.bundle.js'
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.12
pin "@stimulus-components/sortable", to: "@stimulus-components--sortable.js" # @5.0.3
pin "sortablejs" # @1.15.6
pin "@stimulus-components/notification", to: "@stimulus-components--notification.js" # @3.0.0
pin "stimulus-use" # @0.52.3
