TARGET_PRODUCT_PROP += \
    vendor/lineage/config/defaults_common.prop

$(call inherit-product-if-exists, axion_sdk/ax_tflite/common.mk)

PRODUCT_PACKAGES += \
    AxThemePicker \
    AxQuickLook \
    AxionWidgets \
    AxionParts \
    AxThemeStore
