.PHONY: clean
clean:
	hugo --cleanDestinationDir

.PHONY: server
server: clean
	hugo serve --buildDrafts --buildFuture

.PHONY: deps
deps:
	brew install hugo

.PHONY: build
build: clean
	hugo

DEPLOY_BRANCH := gh-pages
DEPLOY_DIR := public

.PHONY: publish
publish: build
	git symbolic-ref HEAD refs/heads/$(DEPLOY_BRANCH)
	git --work-tree $(DEPLOY_DIR) reset --mixed --quiet
	git --work-tree $(DEPLOY_DIR) add --all
	if git --work-tree $(DEPLOY_DIR) diff-index --quiet HEAD -- ; then \
	  echo "no changes" ; \
	else \
	  git --work-tree $(DEPLOY_DIR) commit -m "deploy " ; \
	  git push origin $(DEPLOY_BRANCH) ; \
	fi

	git symbolic-ref HEAD refs/heads/master
	git reset --mixed
	[ -d $(DEPLOY_DIR) ] && rm -rf $(DEPLOY_DIR)
