// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

#pragma once

#include <stdbool.h>
#include <stdint.h>

// The following structs are used to implement the lowest level
// of the FFI, and thus useful to multiple uniffied crates.
// We ensure they are declared exactly once, with a header guard, UNIFFI_SHARED_H.
#ifdef UNIFFI_SHARED_H
    // We also try to prevent mixing versions of shared uniffi header structs.
    // If you add anything to the #else block, you must increment the version suffix in UNIFFI_SHARED_HEADER_V4
    #ifndef UNIFFI_SHARED_HEADER_V4
        #error Combining helper code from multiple versions of uniffi is not supported
    #endif // ndef UNIFFI_SHARED_HEADER_V4
#else
#define UNIFFI_SHARED_H
#define UNIFFI_SHARED_HEADER_V4
// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️

typedef struct RustBuffer
{
    int32_t capacity;
    int32_t len;
    uint8_t *_Nullable data;
} RustBuffer;

typedef int32_t (*ForeignCallback)(uint64_t, int32_t, RustBuffer, RustBuffer *_Nonnull);

typedef struct ForeignBytes
{
    int32_t len;
    const uint8_t *_Nullable data;
} ForeignBytes;

// Error definitions
typedef struct RustCallStatus {
    int8_t code;
    RustBuffer errorBuf;
} RustCallStatus;

// ⚠️ Attention: If you change this #else block (ending in `#endif // def UNIFFI_SHARED_H`) you *must* ⚠️
// ⚠️ increment the version suffix in all instances of UNIFFI_SHARED_HEADER_V4 in this file.           ⚠️
#endif // def UNIFFI_SHARED_H

void ffi_nimbus_e811_NimbusClient_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull nimbus_e811_NimbusClient_new(
      RustBuffer app_ctx,RustBuffer dbpath,RustBuffer remote_settings_config,RustBuffer available_randomization_units,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_initialize(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_get_experiment_branch(
      void*_Nonnull ptr,RustBuffer id,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_get_feature_config_variables(
      void*_Nonnull ptr,RustBuffer feature_id,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_get_experiment_branches(
      void*_Nonnull ptr,RustBuffer experiment_slug,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_get_active_experiments(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_get_enrollment_by_feature(
      void*_Nonnull ptr,RustBuffer feature_id,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_get_available_experiments(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
int8_t nimbus_e811_NimbusClient_get_global_user_participation(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_set_global_user_participation(
      void*_Nonnull ptr,int8_t opt_in,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_fetch_experiments(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_set_fetch_enabled(
      void*_Nonnull ptr,int8_t flag,
    RustCallStatus *_Nonnull out_status
    );
int8_t nimbus_e811_NimbusClient_is_fetch_enabled(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_apply_pending_experiments(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_set_experiments_locally(
      void*_Nonnull ptr,RustBuffer experiments_json,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_reset_enrollments(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_opt_in_with_branch(
      void*_Nonnull ptr,RustBuffer experiment_slug,RustBuffer branch,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_opt_out(
      void*_Nonnull ptr,RustBuffer experiment_slug,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusClient_reset_telemetry_identifiers(
      void*_Nonnull ptr,RustBuffer new_randomization_units,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull nimbus_e811_NimbusClient_create_targeting_helper(
      void*_Nonnull ptr,RustBuffer additional_context,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull nimbus_e811_NimbusClient_create_string_helper(
      void*_Nonnull ptr,RustBuffer additional_context,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_record_event(
      void*_Nonnull ptr,RustBuffer event_id,int64_t count,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_record_past_event(
      void*_Nonnull ptr,RustBuffer event_id,int64_t seconds_ago,int64_t count,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_advance_event_time(
      void*_Nonnull ptr,int64_t by_seconds,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_clear_events(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void nimbus_e811_NimbusClient_dump_state_to_log(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void ffi_nimbus_e811_NimbusTargetingHelper_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
int8_t nimbus_e811_NimbusTargetingHelper_eval_jexl(
      void*_Nonnull ptr,RustBuffer expression,
    RustCallStatus *_Nonnull out_status
    );
void ffi_nimbus_e811_NimbusStringHelper_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusStringHelper_string_format(
      void*_Nonnull ptr,RustBuffer template,RustBuffer uuid,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer nimbus_e811_NimbusStringHelper_get_uuid(
      void*_Nonnull ptr,RustBuffer template,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_nimbus_e811_rustbuffer_alloc(
      int32_t size,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_nimbus_e811_rustbuffer_from_bytes(
      ForeignBytes bytes,
    RustCallStatus *_Nonnull out_status
    );
void ffi_nimbus_e811_rustbuffer_free(
      RustBuffer buf,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_nimbus_e811_rustbuffer_reserve(
      RustBuffer buf,int32_t additional,
    RustCallStatus *_Nonnull out_status
    );
