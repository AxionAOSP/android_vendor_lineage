TARGET_PRODUCT_PROP += \
    vendor/lineage/config/defaults_common.prop

$(call inherit-product-if-exists, axion_sdk/ax_tflite/common.mk)

PRODUCT_PACKAGES += \
    AxThemePicker \
    AxQuickLook \
    AxionWidgets \
    AxionParts \
    AxThemeStore \
    AxPcMode \
    AxSandbox \
    EdgeLauncher \
    GameSpace \
    OmniJaws \
    ColumbusService
    
# eliminate interpreter overhead
PRODUCT_DEXPREOPT_SPEED_APPS += \
    Settings \
    AxThemePicker \
    AxionParts \
    EdgeLauncher \
    GameSpace

TARGET_INCLUDE_AXFX ?= false
ifeq ($(TARGET_INCLUDE_AXFX),true)
$(call inherit-product-if-exists, packages/apps/AxionFx/config.mk)
endif

$(call inherit-product-if-exists, packages/apps/FaceUnlock/common.mk)
