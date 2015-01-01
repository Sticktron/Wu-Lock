DEBUG = 1


ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages

TWEAK_NAME = WuLock
WuLock_FILES = Tweak.xm
WuLock_FRAMEWORKS = UIKit CoreGraphics QuartzCore

SUBPROJECTS += Settings

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

# some optimizations...
after-stage::
	find $(FW_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
	find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;

after-install::
	install.exec "killall -HUP SpringBoard"

