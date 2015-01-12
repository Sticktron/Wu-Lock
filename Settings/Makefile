ARCHS = armv7 arm64
TARGET = iphone:clang:latest:8.0

BUNDLE_NAME = Wu-Lock
Wu-Lock_CFLAGS = -fobjc-arc
Wu-Lock_FILES = WuLockSettings.mm
Wu-Lock_INSTALL_PATH = /Library/PreferenceBundles
Wu-Lock_FRAMEWORKS = UIKit CoreGraphics
Wu-Lock_PRIVATE_FRAMEWORKS = Preferences

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WuLockSettings.plist$(ECHO_END)
