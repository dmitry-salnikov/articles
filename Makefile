clean:
	hugo --cleanDestinationDir

server: clean
	hugo serve --buildDrafts --buildFuture

deps:
	brew install hugo

build: clean
	hugo

publish: build
	gsutil -m rsync -R _site/  gs://b.lumberjaph.net
	gsutil -m acl ch -u AllUsers:R -R gs://b.lumberjaph.net/
	gsutil -m web set -m index.html -e 404.html gs://b.lumberjaph.net

.PHONY: build clean server deps publish
