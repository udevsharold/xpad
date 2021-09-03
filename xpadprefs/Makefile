ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = XPadPrefs

XPadPrefs_FILES = $(wildcard *.m) $(wildcard *.mm) ../XPPrefsManager.m ../XPShortcutsGenerator.m ../XPHelper.m
XPadPrefs_INSTALL_PATH = /Library/PreferenceBundles
XPadPrefs_FRAMEWORKS = UIKit
XPadPrefs_PRIVATE_FRAMEWORKS = Preferences AppSupport
XPadPrefs_CFLAGS = -fobjc-arc
XPadPrefs_LIBRARIES = rocketbootstrap sparkcolourpicker


include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/XPadPrefs.plist$(ECHO_END)
