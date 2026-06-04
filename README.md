# Vi Translator

A flashcard app for language learning, built with Rails 8. Organize translation
cards into collections and study them with click-to-flip flashcards — the front
shows a word or phrase, the back reveals its translation.

## Features

- **Collections** of flashcards, each tied to a language
- **Cards** with front/back text and a source → target language pair
- **Click-to-flip study view** — tap a card to reveal the translation
- **User accounts** with a native language and a language you're learning (Devise)
- Responsive **Bootstrap 5** UI

## Tech stack

- **Ruby on Rails 8.1** (Ruby 3.4.8, see `.ruby-version`)
- **PostgreSQL**
- **Hotwire** (Turbo + Stimulus) with **importmap** — no JS bundler
- **Bootstrap 5** compiled via **dartsass-rails**, served by **Propshaft**
- **Devise** for authentication
- **RSpec** + FactoryBot for tests
- **Solid Queue / Cache / Cable**; deployable with **Kamal**

## Getting started

### Prerequisites

- Ruby 3.4.8
- PostgreSQL (running locally)

### Setup

```bash
bin/setup            # installs gems, prepares the database, and boots the app
```

Or step by step:

```bash
bundle install
bin/rails db:prepare # create database and load the schema
bin/rails db:seed    # seed the 12 starter languages
```

> The app ships with a seed list of 12 languages (`db/seeds.rb`). Most features
> assume languages exist, so run `db:seed` before creating collections or cards.

### Running

```bash
bin/dev              # starts Puma + the dartsass CSS watcher (Procfile.dev)
```

Then visit http://localhost:3000. Sign up at `/auth/register/cmon_let_me_in`
(auth routes live under `/auth` — e.g. log in at `/auth/login`).

## Testing

```bash
bundle exec rspec                          # full suite
bundle exec rspec spec/models/card_spec.rb # a single file
```

## Other commands

```bash
bin/rubocop                  # lint (rubocop-rails-omakase)
bin/brakeman                 # security scan
bin/rails dartsass:build     # compile CSS once (watch runs via bin/dev)
```

## Notes

- On **macOS 13**, `sass-embedded` is pinned to `~> 1.77.0` in the `Gemfile`
  because newer releases require macOS 14. Bump it once you're on macOS 14+.
