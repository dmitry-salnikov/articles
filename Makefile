build: clean
	bundle exec jekyll build

clean:
	rm -rf _site

server: clean
	bundle exec jekyll server --port 3001 --watch --drafts

deps:
	bundle install --path vendor/bundle

test: build
	bundle exec htmlproof ./_site --only-4xx --check-html --disable-external

publish: deps build
	gsutil -m rsync -R _site/  gs://b.lumberjaph.net
	gsutil -m acl ch -u AllUsers:R -R gs://b.lumberjaph.net/
	gsutil -m web set -m index.html -e 404.html gs://b.lumberjaph.net

