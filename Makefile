#! @revision   2020-08-19 (Wed) 21:26:44
#! @brief      Makefile port of Bootstrap 4's _npm_ build

SHELL          = /bin/ksh

NAME           = bootstrap
DESCRIPTION    = The most popular front-end framework for developing responsive, mobile first projects on the web.
VERSION        = 5.0.0-alpha1
VERSION_SHORT  = 5.0
TARBALL        = v$(VERSION).tar.gz
SOURCEURL      = https://github.com/twbs/bootstrap/archive/$(TARBALL)
SOURCEDIR      = $(NAME)-$(VERSION)
HOMEPAGE       = https://getbootstrap.com/
AUTHOR         = The Bootstrap Authors (https://github.com/twbs/bootstrap/graphs/contributors)
STYLE          = dist/css/bootstrap.css
SASS           = scss/bootstrap.scss
MAIN           = dist/js/bootstrap.js
GITURL         = git+https://github.com/twbs/bootstrap.git
ISSUESURL      = https://github.com/twbs/bootstrap/issues
LICENSE        = MIT

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
ESLINT_OPTS    = eslint --report-unused-disable-directives --cache --cache-location .cache/.eslintcache
FUSV           = $(NODEBIN)/fusv
FUSV_OPTS      =
KARMA          = $(NODEBIN)/karma
KARMA_OPTS     =
LINKINATOR     = $(NODEBIN)/linkinator
LOCKLINT       = $(NODEBIN)/lockfile-lint
LOCKLINT_OPTS  = --allowed-hosts npm --allowed-schemes https: --empty-hostname false --type npm
NODEMON        = $(NODEBIN)/ṅodemon
NODEMON_OPTS   = 
POSTCSS        = $(NODEBIN)/postcss
POSTCSS_OPTS   = --config build/postcss.config.js
ROLLUP         = $(NODEBIN)/rollup
ROLLUP_OPTS    =
SASSC          = $(NODEBIN)/node-sass
SASSC_OPTS     = --output-style expanded --source-map true --source-map-contents true --precision 6
STYLELINT      = $(NODEBIN)/stylelint
STYLELINT_OPTS = --cache --cache-location .cache/.stylelintcache
TERSER         = $(NODEBIN)/terser
TERSER_OPTS    = --compress typeofs=false --mangle --comments "/^!/"


all: dist

bundlewatch:
	$(BUNDLEWATCH) --config .bundlewatch.config.json

clean:
	@[[ -d dist ]] && rm -rf dist; true

css: css-compile css-prefix css-minify css-copy

css-compile: css-compile-main css-compile-docs

css-compile-main:
	@$(SASSC) $(SASSC_OPTS) scss/ -o dist/css/ && make css-copy

css-compile-docs: $(DOCS_ASSETSDIR)/scss/docs.scss $(DOCS_ASSETSDIR)/css/docs.min.css
	@$(SASSC) $(SASSC_OPTS) $^

css-copy:
	@[[ -d $(DOCS_DISTDIR) ]] || mkdir -p $(DOCS_DISTDIR)
	@cp -r dist/css/ $(DOCS_DISTDIR)

css-docs: css-compile-docs css-prefix-docs css-minify-docs

css-lint: css-lint-main css-lint-docs

css-lint-main:
	@$(STYLELINT) $(STYLELINT_OPTS) "scss/**/*.scss"

css-lint-docs:
	@$(STYLELINT) $(STYLELINT_OPTS) "site/docs/**/assets/scss/*.scss" "site/docs/**/*.css"

css-lint-vars:
	@$(FUSV) $(FUSV_OPTS) scss/ site/docs/

css-main:
	@npm-run-all css-lint css-compile-main css-prefix-main css-minify-main css-copy

css-minify: css-minify-main css-minify-docs

css-minify-main:
	@$(CLEANCSS) $(CLEANCSS_OPTS) --output dist/css/bootstrap.min.css dist/css/bootstrap.css
	@$(CLEANCSS) $(CLEANCSS_OPTS) --output dist/css/bootstrap-grid.min.css dist/css/bootstrap-grid.css
	@$(CLEANCSS) $(CLEANCSS_OPTS) --output dist/css/bootstrap-reboot.min.css dist/css/bootstrap-reboot.css

css-minify-docs:
	@$(CLEANCSS) $(CLEANCSS_OPTS) --output $^ $^ $(DOCS_ASSETSDIR)/css/docs.min.css $(DOCS_ASSETSDIR)/css/docs.min.css

css-prefix: css-prefix-main css-prefix-docs

css-prefix-main:
	@$(POSTCSS) $(POSTCSS_OPTS) --replace "dist/css/*.css" "!dist/css/*.min.css"

css-prefix-docs:
	@$(POSTCSS) $(POSTCSS_OPTS) --replace "site/docs/**/*.css"

dist: css js

docs: css-docs js-docs docs-build docs-lint

docs-build:
	@bundle exec jekyll build

docs-compile: docs-build
	@npm run docs-build

docs-production:
	@JEKYLL_ENV=production $(MAKE) docs-build

docs-netlify:
	@JEKYLL_ENV=netlify $(MAKE) docs-build

docs-linkinator:
	@$(LINKINATOR) _gh_pages --recurse --silent --skip \"^(?!http://localhost)\"

docs-vnu:
	@node build/vnu-jar.js

docs-lint: docs-vnu docs-linkinator

docs-serve:
	@bundle exec jekyll serve

docs-serve-only:
	@bundle exec jekyll serv --skip-initial-build --no-watche

distclean: realclean
	@rm -rf $$(ls -1a | egrep -v '^(\.|\.\.|\.git|Makefile|README.md|migration)$$'); true

init: package.json
	@npm install

js: js-compile js-minify js-copy

js-copy:
	@mkdir -p site/docs/$(VERSION_SHORT)/dist/
	@cp -r dist/js/ site/docs/$(VERSION_SHORT)/dist/

js-main: js-lint js-compile js-minify-main

js-docs: js-lint-docs js-minify-docs

js-compile: js-compile-bundle js-compile-plugins js-compile-plugins-coverage js-compile-standalone js-copy

js-compile-bundle:
	@$(ROLLUP) $(ROLLUP_OPTS) --environment BUNDLE:true --config build/rollup.config.js --sourcemap

js-compile-plugins:
	@node build/build-plugins.js

js-compile-plugins-coverage:
	@NODE_ENV=test node build/build-plugins.js

js-compile-standalone:
	@$(ROLLUP) $(ROLLUP_OPTS) --environment BUNDLE:false --config build/rollup.config.js --sourcemap

js-lint: js-lint-main js-lint-docs

js-lint-main:
	@$(ESLINT) $(ESLINT_OPTS) js/src js/tests build/

js-lint-docs:
	@$(ESLINT) $(ESLINT_OPTS) site/

js-minify: js-minify-main js-minify-docs

js-minify-main: js-minify-standalone js-minify-bundle

js-minify-standalone:
	@$(TERSER) $(TERSER_OPTS) \
	    --source-map "content=dist/js/bootstrap.js.map,includeSources,url=bootstrap.min.js.map" \
	    --output dist/js/bootstrap.min.js dist/js/bootstrap.js

js-minify-bundle:
	@$(TERSER) $(TERSER_OPTS) \
	--source-map "content=dist/js/bootstrap.bundle.js.map,includeSources,url=bootstrap.bundle.min.js.map" \
	--output dist/js/bootstrap.bundle.min.js dist/js/bootstrap.bundle.js

js-minify-docs:
	@$(TERSER) $(TERSER_OPTS) --output $(DOCS_ASSETSDIR)/js/docs.min.js \
	    $(DOCS_ASSETSDIR)/js/vendor/anchor.min.js \
	    $(DOCS_ASSETSDIR)/js/vendor/clipboard.min.js \
	    $(DOCS_ASSETSDIR)/js/vendor/bs-custom-file-input.min.js \
	    "$(DOCS_ASSETSDIR)/js/src/*.js"

js-test: js-test-karma js-test-karma-bundle js-test-karma-bundle-old js-test-integration js-test-cloud

js-test-karma:
	@$(KARMA) $(KARMA_OPTS) start js/tests/karma.conf.js

js-test-karma-old:
	@USE_OLD_JQUERY=true $(MAKE) js-test-karma

js-test-karma-bundle:
	@BUNDLE=true npm run js-test-karma

js-test-karma-bundle-old:
	@BUNDLE=true USE_OLD_JQUERY=true $(MAKE) js-test-karma

js-test-integration:
	@$(ROLLUP) $(ROLLUP_OPTS) --config js/tests/integration/rollup.bundle.js

js-test-cloud:
	@BROWSER=true $(MAKE) js-test-karma

lint: js-lint css-lint lockfile-lint

lockfile-lint:
	@$(LOCKLINT) $(LOCKLINT_OPTS) --path package-lock.json

netlify: dist release-sri docs-netlify

package.json:
	@[[ -f $(TARBALL)        ]] || curl -SsLO $(SOURCEURL)
	@[[ -d $(SOURCEDIR)      ]] || tar xf $(TARBALL)
	@[[ -d $(SOURCEDIR)/.git ]] && rm -rf $(SOURCEDIR)/.git; true
	@[[ -f package.json      ]] || mv -n $(SOURCEDIR)/* $(SOURCEDIR)/.* .
	@[[ -d $(SOURCEDIR)      ]] && rm -rf $(SOURCEDIR); true
	@[[ -f $(TARBALL)        ]] && rm $(TARBALL); true

realclean: clean
	rm -rf node_modules

release: dist release-sri docs-production release-zip release-zip-examples

release-sri:
	@node build/generate-sri.js

release-version:
	@node build/change-version.js

release-zip:
	@rm -rf bootstrap-$npm_package_version-dist
	@cp -r dist/ bootstrap-$npm_package_version-dist
	@zip -r9 bootstrap-$npm_package_version-dist.zip bootstrap-$npm_package_version-dist
	@rm -rf bootstrap-$npm_package_version-dist\"

release-zip-examples:
	@node build/zip-examples.js

start: watch docs-serve

test: lint dist js-test docs-build docs-lint

update-deps:
	@ncu -u -x "jquery,karma-browserstack-launcher,sinon"
	@npm update && bundle update
	@echo Manually update "site/docs/$(VERSION_SHORT)/assets/js/vendor/"

watch: watch-css-docs watch-css-main watch-js-docs watch-js-main

watch-css-docs:
	@$(NODEMON) --watch "site/docs/**/assets/scss/" --ext scss --exec "npm run css-docs"

watch-css-main:
	@$(NODEMON) --watch scss/ --ext scss --exec "npm run css-main"

watch-js-docs:
	@$(NODEMON) --watch "site/docs/**/assets/js/src/" --ext js --exec "npm run js-docs"

watch-js-main:
	@$(NODEMON) --watch js/src/ --ext js --exec "npm run js-compile"


# vim: nospell
