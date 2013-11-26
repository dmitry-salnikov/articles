build: clean
	bundle exec jekyll build

clean:
	rm -rf _site

server: clean
	bundle exec jekyll server --watch

publish: build
	@rsync -avz --exclude Makefile --exclude README.md _site/ fcuny@lumberjaph.net:~/sites/lumberjaph.net
