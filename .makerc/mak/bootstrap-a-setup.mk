#! @revision  2021-04-13 (Tue) 17:55:30
#! @brief     Makefile port of Bootstrap's npm(1) build

NAME           = bootstrap
DESCRIPTION    = The most popular front-end framework for developing responsive, mobile first projects on the web.
VERSION        = 5.0.0-beta1
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
BUNDLEWATCH    = bundlewatch
CLEANCSS       = cleancss --level 1 --format breakWith=lf --source-map --source-map-inline-sources
ESLINT         = eslint --report-unused-disable-directives --cache --cache-location .cache/.eslintcache
FUSV           = fusv
HUGO           = hugo
KARMA          = karma
LINKINATOR     = linkinator
LOCKLINT       = lockfile-lint --allowed-hosts npm --allowed-schemes https: --empty-hostname false --type npm
NODE           = /usr/local/bin/node
NODEMON        = nodemon --watch
NPM            = /usr/local/bin/npm
POSTCSS        = postcss --config build/postcss.config.js
ROLLUP         = rollup
SASSC          = sass --style expanded --source-map --embed-sources --no-error-css
SIRV           = sirv
STYLELINT      = stylelint --cache --cache-location .cache/.stylelintcache
TERSER         = terser --compress typeofs=false --mangle --comments /^!/

# vim: noet fdm=marker fmr=@{,@} ts=4
