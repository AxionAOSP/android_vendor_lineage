TARGET_PRODUCT_PROP += \
    vendor/lineage/config/defaults_common.prop

PRODUCT_PACKAGES += \
    EdgeLauncher \
    AxThemeStore \
    AxThemePicker \
    AxSandbox \
    AxionWidgets \
    GameSpace \
    OmniJaws \
    ColumbusService \
    AxionParts
    
# Enable blur
TARGET_ENABLE_BLUR ?= true
ifeq ($(TARGET_ENABLE_BLUR),true)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.custom.blur.enable=true
else
PRODUCT_SYSTEM_PROPERTIES += \
    ro.custom.blur.enable=false
endif
