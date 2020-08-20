#! @revision  Thu Aug 20 03:09:04 CEST 2020
#! @brief     Makefile port of Bootstrap 5.0's npm(1) build

SHELL          = /bin/ksh

NAME           = bootstrap
DESCRIPTION    = The most popular front-end framework for developing responsive, mobile first projects on the web.
VERSION        = 5.0.0-alpha1
VERSION_SHORT  = 5.0
LICENSE        = MIT

TARBALL        = v\$(VERSION).tar.gz
SOURCEURL      = https://github.com/twbs/bootstrap/archive/\$(TARBALL)
SOURCEDIR      = $(NAME)-$(VERSION)
HOMEPAGE       = https://getbootstrap.com/
AUTHOR         = The Bootstrap Authors (https://github.com/twbs/bootstrap/graphs/contributors)
STYLE          = dist/css/bootstrap.css
SASS           = scss/bootstrap.scss
MAIN           = dist/js/bootstrap.js
GITURL         = git+https://github.com/twbs/bootstrap.git
ISSUESURL      = https://github.com/twbs/bootstrap/issues
DISTFILES      = dist/{css,js}/*.{css,js,map}
JSFILES        = js/{src,dist}/**/*.{js,map}
SCSSFILES      = scss/**/*.scss
DOCS_PREFIX    = site/docs/$(VERSION_SHORT)
DOCS_DISTDIR   = $(DOCS_PREFIX)/dist
DOCS_ASSETSDIR = $(DOCS_PREFIX)/assets
NODEBIN        = node_modules/.bin
BUNDLEWATCH    = $(NODEBIN)/bundlewatch
CLEANCSS       = $(NODEBIN)/cleancss
CLEANCSS_OPTS  = --level 1 --format breakWith=lf --source-map --source-map-inline-sources
ESLINT         = $(NODEBIN)/eslint
ESLINT_OPTS    = --report-unused-disable-directives --cache --cache-location .cache/.eslintcache
FUSV           = $(NODEBIN)/fusv
FUSV_OPTS      =
HUGO           = $(NODEBIN)/hugo
KARMA          = $(NODEBIN)/karma
KARMA_OPTS     =
LINKINATOR     = $(NODEBIN)/linkinator
LOCKLINT       = $(NODEBIN)/lockfile-lint
LOCKLINT_OPTS  = --allowed-hosts npm --allowed-schemes https: --empty-hostname false --type npm
NODE           = /usr/local/bin/node
NODEMON        = $(NODEBIN)/ṅodemon
NODEMON_OPTS   = 
NPM            = /usr/local/bin/npm
POSTCSS        = $(NODEBIN)/postcss
POSTCSS_OPTS   = --config build/postcss.config.js
ROLLUP         = $(NODEBIN)/rollup
ROLLUP_OPTS    =
SASSC          = $(NODEBIN)/node-sass
SASSC_OPTS     = --output-style expanded --source-map true --source-map-contents true --precision 6
SIRV           = $(NODEBIN)/sirv
STYLELINT      = $(NODEBIN)/stylelint
STYLELINT_OPTS = --cache --cache-location .cache/.stylelintcache
TERSER         = $(NODEBIN)/terser
TERSER_OPTS    = --compress typeofs=false --mangle --comments /^!/

all: dist

remake:
	@source ./Makefuncs; jsontomakefile package.json > Makefile.new

package.json:
	@[[ -f $(TARBALL)        ]] || curl -SsLO $(SOURCEURL)
	@[[ -d $(SOURCEDIR)      ]] || tar xf $(TARBALL)
	@[[ -d $(SOURCEDIR)/.git ]] && rm -rf $(SOURCEDIR)/.git; true
	@[[ -f package.json      ]] || mv -n $(SOURCEDIR)/* $(SOURCEDIR)/.* .
	@[[ -d $(SOURCEDIR)      ]] && rm -rf $(SOURCEDIR); true
	@[[ -f $(TARBALL)        ]] && rm $(TARBALL); true

init: package.json
	@npm install

clean:
	@[[ -d dist ]] && rm -rf dist; true

realclean: clean
	@rm -rf node_modules

distclean: realclean
	@rm -rf $$(ls -1a | egrep -v '^(\.|\.\.|\.git|Make.*|README.md)$$'); true

bundlewatch:
	@$(BUNDLEWATCH) $(BUNDLEWATCH_OPTS) --config .bundlewatch.config.json

css: css-compile css-prefix css-minify

css-compile:
	@$(SASSC) $(SASSC_OPTS)  scss/ -o dist/css/

css-lint: css-lint-$(STYLELINT) $(STYLELINT_OPTS) css-lint-vars

css-lint-stylelint:
	@$(STYLELINT) $(STYLELINT_OPTS)  "**/*.{css,scss}"-location .cache/.stylelintcache

css-lint-vars:
	@$(FUSV) $(FUSV_OPTS) scss/ site/assets/scss/

css-minify:
	@$(CLEANCSS) $(CLEANCSS_OPTS)  --output dist/css/bootstrap.min.css dist/css/bootstrap.css
	@$(CLEANCSS) $(CLEANCSS_OPTS) --output dist/css/bootstrap-grid.min.css dist/css/bootstrap-grid.css
	@$(CLEANCSS) $(CLEANCSS_OPTS) --output dist/css/bootstrap-utilities.min.css dist/css/bootstrap-utilities.css
	@$(CLEANCSS) $(CLEANCSS_OPTS) --output dist/css/bootstrap-reboot.min.css dist/css/bootstrap-reboot.css

css-prefix: css-prefix-examples css-prefix-main

css-prefix-examples:
	@$(POSTCSS) $(POSTCSS_OPTS) postcss.config.js//postcss.config.js --replace "site/content/**/*.css"

css-prefix-main:
	@$(POSTCSS) $(POSTCSS_OPTS) postcss.config.js//postcss.config.js --replace "dist/css/*.css" "!dist/css/*.min.css"

dist: css js

docs: docs-build docs-lint

docs-build:
	@$(HUGO) $(HUGO_OPTS) --cleanDestinationDir

docs-compile:
	@$(NPM) $(NPM_OPTS) run docs-build

docs-linkinator:
	@$(LINKINATOR) $(LINKINATOR_OPTS) _gh_pages --recurse --silent --skip "^(?!http://localhost)"

docs-lint: docs-vnu docs-linkinator

docs-serve:
	@$(HUGO) $(HUGO_OPTS) server --port 9001 --disableFastRender

docs-serve-only:
	@$(SIRV) $(SIRV_OPTS) _gh_pages --port 9001

docs-vnu:
	@$(NODE) $(NODE_OPTS) build/vnu-jar.js

js: js-compile js-minify

js-compile: js-compile-bundle js-compile-plugins js-compile-standalone js-compile-standalone-esm

js-compile-bundle:
	@$(ROLLUP) $(ROLLUP_OPTS) --environment BUNDLE:true --config build/rollup.config.js --sourcemap

js-compile-plugins:
	@$(NODE) $(NODE_OPTS) build/build-plugins.js

js-compile-standalone:
	@$(ROLLUP) $(ROLLUP_OPTS) --environment BUNDLE:false --config build/rollup.config.js --sourcemap

js-compile-standalone-esm:
	@$(ROLLUP) $(ROLLUP_OPTS) --environment ESM:true,BUNDLE:false --config build/rollup.config.js --sourcemap

js-debug:
	@DEBUG=true $(NPM) $(NPM_OPTS) run js-test-karma

js-lint:
	@$(ESLINT) $(ESLINT_OPTS)  .

js-minify: js-minify-bundle js-minify-standalone js-minify-standalone-esm

js-minify-bundle:
	$(TERSER) $(TERSER_OPTS)  --source-map "content=dist/js/bootstrap.bundle.js.map,includeSources,url=bootstrap.bundle.min.js.map" --output dist/js/bootstrap.bundle.min.js dist/js/bootstrap.bundle.js

js-minify-standalone:
	$(TERSER) $(TERSER_OPTS)  --source-map "content=dist/js/bootstrap.js.map,includeSources,url=bootstrap.min.js.map" --output dist/js/bootstrap.min.js dist/js/bootstrap.js

js-minify-standalone-esm:
	$(TERSER) $(TERSER_OPTS)  --source-map "content=dist/js/bootstrap.esm.js.map,includeSources,url=bootstrap.esm.min.js.map" --output dist/js/bootstrap.esm.min.js dist/js/bootstrap.esm.js

js-test: js-test-$(KARMA) $(KARMA_OPTS) js-test-jquery js-test-integration

js-test-cloud:
	@BROWSER=true $(NPM) $(NPM_OPTS) run js-test-karma

js-test-integration:
	@$(ROLLUP) $(ROLLUP_OPTS) --config js/tests/integration/rollup.bundle.js
	@$(ROLLUP) $(ROLLUP_OPTS) --config js/tests/integration/rollup.bundle-modularity.js

js-test-jquery:
	@JQUERY=true $(NPM) $(NPM_OPTS) run js-test-karma

js-test-karma:
	@$(KARMA) $(KARMA_OPTS) start js/tests/karma.conf.js

lint: js-lint css-lint lockfile-lint

lockfile-lint:
	@$(LOCKLINT) $(LOCKLINT_OPTS)  --path package-lock.json

netlify:
	@HUGO_BASEURL=$DEPLOY_PRIME_URL $(MAKE) dist release-sri docs-build

release: dist release-sri docs-build release-zip release-zip-examples

release-sri:
	@$(NODE) $(NODE_OPTS) build/generate-sri.js

release-version:
	@$(NODE) $(NODE_OPTS) build/change-version.js

release-zip:
	@rm -rf bootstrap-$(VERSION)-dist
	@cp -r dist/ bootstrap-$(VERSION)-dist
	@zip -r9 bootstrap-$(VERSION)-dist.zip bootstrap-$(VERSION)-dist
	@rm -rf bootstrap-$(VERSION)-dist

release-zip-examples:
	@$(NODE) $(NODE_OPTS) build/zip-examples.js

start: watch docs-serve

test: lint dist js-test docs-build docs-lint

update-deps:
	@$(NCU) $(NCU_OPTS) -u -x karma-browserstack-launcher,popper.js
	@$(NPM) $(NPM_OPTS) update
	@echo Manually update site/assets/js/vendor

watch: watch-css-docs watch-css-main watch-js-docs watch-js-main

watch-css-docs:
	@$(NODEMON) $(NODEMON_OPTS) --watch site/assets/scss/ --ext scss --exec "$(NPM) $(NPM_OPTS) run css-lint"

watch-css-main:
	@$(NODEMON) $(NODEMON_OPTS) --watch scss/ --ext scss --exec "$(MAKE) css-lint css-compile css-prefix"

watch-js-docs:
	@$(NODEMON) $(NODEMON_OPTS) --watch site/assets/js/ --ext js --exec "$(NPM) $(NPM_OPTS) run js-lint"

watch-js-main:
	@$(NODEMON) $(NODEMON_OPTS) --watch js/src/ --ext js --exec "$(MAKE) js-lint js-compile"

