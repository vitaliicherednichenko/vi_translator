# Pin npm packages by running ./bin/importmap

pin "application"
pin "preserve_scroll"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", preload: true # @5.3.8
pin "@popperjs/core", to: "@popperjs--core.js", preload: true # @2.11.8
