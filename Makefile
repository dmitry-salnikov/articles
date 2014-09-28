build: clean
	bundle exec jekyll build

clean:
	rm -rf _site

server: clean
	bundle exec jekyll server --port 3001 --watch --drafts

publish: build
	rsync -chavzOP --stats _site/ /srv/www/lumberjaph.net/

deps:
	bundle install
