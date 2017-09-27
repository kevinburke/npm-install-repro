SHELL := /bin/bash -o pipefail

# Use a local NPM so we can cache it and avoid needing to reinstall NPM 5 on
# every build.
#
# NOTE: you cannot install this into the node_modules directory; NPM has some
# weird "unbuild" step where node-gyp gets uninstalled when you try to install
# anything else.
NPM := bin/npm
NPM_VERSION := v5.4.2
NPM_OPTS = --color=false --send-metrics=false --progress=false --prefer-offline

GLOBAL_NPM = $(shell command -v npm)
ifeq ($(GLOBAL_NPM),)
	GLOBAL_NPM = rebuild
endif

logs:
	mkdir -p logs

# you can't install this into the NPM cache or npm will complain.
var/src/$(NPM_VERSION).tar.gz:
	mkdir -p var/src
	curl --location --silent https://github.com/npm/npm/archive/$(NPM_VERSION).tar.gz > var/src/$(NPM_VERSION).tar.gz

$(NPM): var/src/$(NPM_VERSION).tar.gz | $(GLOBAL_NPM) logs
	# this might be npm 2
	time $(GLOBAL_NPM) install --global --prefix=${CURDIR} $(NPM_OPTS) --cache-min 9999999 var/src/$(NPM_VERSION).tar.gz > logs/npm-local-install.log 2>&1; \
		if [[ "$$?" != 0 ]]; then \
			cat logs/npm-local-install.log; \
			exit 1; \
		fi
	$(NPM) --version
