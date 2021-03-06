ARCHS = armv7 arm64
TARGET = iphone:clang:latest:8.0
THEOS_BUILD_DIR = Packages

TWEAK_NAME = Wu-Lock
Wu-Lock_CFLAGS = -fobjc-arc
Wu-Lock_FILES = Tweak.xm
Wu-Lock_FRAMEWORKS = UIKit CoreGraphics QuartzCore

SUBPROJECTS += Settings

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

# optimize (pincrush pngs; convert plists to binary)
after-stage::
	find $(FW_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
	find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;

after-install::
	install.exec "killall -9 backboardd"
