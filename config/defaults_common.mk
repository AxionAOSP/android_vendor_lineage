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
TARGET_ENABLE_BLUR ?= false
ifeq ($(TARGET_ENABLE_BLUR),true)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.custom.blur.enable=true \
    persist.sys.fs.disable_blurs=0
else
PRODUCT_SYSTEM_PROPERTIES += \
    ro.custom.blur.enable=false \
    persist.sys.fs.disable_blurs=1
endif

PRODUCT_SYSTEM_PROPERTIES += ro.surface_flinger.supports_background_blur=1
