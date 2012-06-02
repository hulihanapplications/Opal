When you're ready to release, do this:

1. Make sure all tests are passing.

    	bundle exec rspec spec/

2. Merge dev branch into master

		git checkout master
		git merge dev

3. Tag It!

		git tag -a v1.0.x -m 'version 1.0.x'

4. Push

		git push origin master
		git push v1.0.x