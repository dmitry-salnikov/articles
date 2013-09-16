build: clean
	jekyll build

clean:
	rm -rf _site

server: clean
	jekyll server --watch

publish: build
	@rsync -avz --exclude Makefile --exclude README.md _site/ franck@198.199.119.67:~/sites/lumberjaph.net
