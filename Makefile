build: clean
	bundle exec jekyll build

clean:
	rm -rf _site

server: clean
	bundle exec jekyll server --port 3001 --watch --drafts

publish: build
	mkdir -p /data/www/lumberjaph.net
	rsync -chavzOP --stats _site/ /data/www/lumberjaph.net/

deps:
	bundle install
