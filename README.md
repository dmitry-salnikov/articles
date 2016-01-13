# franckcuny.github.io

[![Build Status](https://travis-ci.org/franckcuny/franckcuny.github.io.svg?branch=master)](https://travis-ci.org/franckcuny/franckcuny.github.io)

## Setup

Ruby's [bundler](http://bundler.io/) is required to set up the blog. Follow the instructions:

+ `sudo apt-get install bundler`
+ `make deps`

## Work on the blog

I don't really care about a clean history for the blog. While writing an article, there's a couple
of useful commands:

+ `make server`: will start a server on http://localhost:3001
+ `make build`: will build the static site
+ `make clean`: will delete all the generated files

## Write an article

## Publish

Start by running `make test` to check that everything is fine. Then run `git push`.
