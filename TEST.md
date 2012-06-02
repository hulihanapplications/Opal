To run the test suite, first, build your test database:

	RAILS_ENV=test bundle exec rake db:migrate
	RAILS_ENV=test bundle exec rake db:seed

Then, run the rspec tests

	bundle exec rspec spec/
