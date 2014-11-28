PNGS=$(shell find static -name "*.png")
JPGS=$(shell find static -name "*.jpg")

PNG2WEBP := $(patsubst %.png,%.webp,$(PNGS))
JPG2WEBP := $(patsubst %.jpg,%.webp,$(JPGS))

images: $(PNG2WEBP) $(JPG2WEBP)

%.webp: %.png
	cwebp -q 100 "$<" -o "$@"

%.webp: %.jpg
	cwebp -q 100 "$<" -o "$@"

build: clean
	bundle exec jekyll build

clean:
	rm -rf _site

server: clean
	bundle exec jekyll server --port 3001 --watch --drafts

publish: build images
	rsync -chavzOP --stats _site/ 104.236.175.223:/srv/www/lumberjaph.net/

deps:
	bundle install --path vendor/bundle
