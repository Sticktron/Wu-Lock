ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0


BUNDLE_NAME = WuLockSettings
WuLockSettings_CFLAGS = -fobjc-arc
WuLockSettings_FILES = WuLockSettings.mm
WuLockSettings_INSTALL_PATH = /Library/PreferenceBundles
WuLockSettings_FRAMEWORKS = UIKit
WuLockSettings_PRIVATE_FRAMEWORKS = Preferences

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WuLockSettings.plist$(ECHO_END)
