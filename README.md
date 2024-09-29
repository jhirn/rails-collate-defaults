# README

Created this because of an edge case found while troublshooting test on a project where Linux (Ubuntu) postgres order_by is different from Ruby default. OSX sort matches Ruby.

IMO it's confusing for Rails' Postgres defaults to be have differently than Ruby, but I also understand the rabit holes of `locale` and machine specific settings. I'm not suggesting the default be changed in Postgres, just illustrating they are different.

## To run

Requirements: Ruby, Docker

```bash
# Docker Issue Script
docker-compose up

# Local Issue Script
docker-compose up -d
ruby rails_issue_template.rb

# To run app locally
bundle install
bin/rails db:setup
bin/rails test
```

Obverve the failing test in test/models/default_collate.test.

I should note that CRuby's sort is the consistent on OSX/Linux. I have not tested Windows.
