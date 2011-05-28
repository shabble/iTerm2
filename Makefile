PATH := /usr/bin:/bin:/usr/sbin:/sbin

ORIG_PATH := $(PATH)
PATH := /usr/bin:/bin:/usr/sbin:/sbin
ITERM_PID=$(shell pgrep "iTerm")
APPS := /Applications
ITERM_CONF_PLIST = $(HOME)/Library/Preferences/com.googlecode.iterm2.plist
ITERM_PRESETS_DIR = ${APPS}/iTerm.app/Contents/Resources
PRESETS_FILE = PresetKeyMappings.plist
NEW_PRESETS_FILE = PresetKeyMappings.plist.tmp
PERL = /opt/local/bin/perl

.PHONY: clean all backup-old-iterm restart presets-install generate-fixterm-presets

all: Deployment

TAGS:
	find . -name "*.[mhMH]" -exec etags -o ./TAGS -a '{}' +

install: | Deployment backup-old-iterm
	cp -r build/Deployment/iTerm.app $(APPS)

generate-fixterm-presets:
	$(PERL) generate-fixterms-mappings.pl

presets-install: generate-fixterm-presets
	cp "${ITERM_PRESETS_DIR}/${PRESETS_FILE}" \
	 "${ITERM_PRESETS_DIR}/${PRESETS_FILE}.bak"
	cp "${NEW_PRESETS_FILE}" "${ITERM_PRESETS_DIR}/${PRESETS_FILE}"

Development:
	echo "Using PATH for build: $(PATH)"
	xcodebuild -parallelizeTargets -alltargets -configuration Development && \
	chmod -R go+rX build/Development

Deployment:
	xcodebuild -parallelizeTargets -alltargets -configuration Deployment && \
	chmod -R go+rX build/Deployment

run: Development
	build/Development/iTerm.app/Contents/MacOS/iTerm

zip: Deployment
	cd build/Deployment && \
	zip -r iTerm_$$(cat ../../version.txt).$$(date '+%Y%m%d').zip iTerm.app

clean:
	xcodebuild -parallelizeTargets -alltargets clean
	rm -rf build
	rm -f *~

backup-old-iterm:
	if [[ -d $(APPS)/iTerm.app.bak ]] ; then rm -fr $(APPS)/iTerm.app.bak ; fi
	if [[ -d $(APPS)/iTerm.app ]] ; then \
	/bin/mv $(APPS)/iTerm.app $(APPS)/iTerm.app.bak ;\
	 cp $(ITERM_CONF_PLIST) $(APPS)/iTerm.app.bak/Contents/ ; \
	fi

restart:
	PATH=$(ORIG_PATH) /usr/bin/open /Applications/iTerm.app &
	/bin/kill -TERM $(ITERM_PID)

