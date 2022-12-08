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

void ffi_tabs_edc9_TabsStore_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull tabs_edc9_TabsStore_new(
      RustBuffer path,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer tabs_edc9_TabsStore_get_all(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsStore_set_local_tabs(
      void*_Nonnull ptr,RustBuffer remote_tabs,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsStore_register_with_sync_manager(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsStore_reset(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer tabs_edc9_TabsStore_sync(
      void*_Nonnull ptr,RustBuffer key_id,RustBuffer access_token,RustBuffer sync_key,RustBuffer tokenserver_url,RustBuffer local_id,
    RustCallStatus *_Nonnull out_status
    );
void*_Nonnull tabs_edc9_TabsStore_bridged_engine(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void ffi_tabs_edc9_TabsBridgedEngine_object_free(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
int64_t tabs_edc9_TabsBridgedEngine_last_sync(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_set_last_sync(
      void*_Nonnull ptr,int64_t last_sync,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer tabs_edc9_TabsBridgedEngine_sync_id(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer tabs_edc9_TabsBridgedEngine_reset_sync_id(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer tabs_edc9_TabsBridgedEngine_ensure_current_sync_id(
      void*_Nonnull ptr,RustBuffer new_sync_id,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_prepare_for_sync(
      void*_Nonnull ptr,RustBuffer client_data,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_sync_started(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_store_incoming(
      void*_Nonnull ptr,RustBuffer incoming_envelopes_as_json,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer tabs_edc9_TabsBridgedEngine_apply(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_set_uploaded(
      void*_Nonnull ptr,int64_t new_timestamp,RustBuffer uploaded_ids,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_sync_finished(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_reset(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
void tabs_edc9_TabsBridgedEngine_wipe(
      void*_Nonnull ptr,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_tabs_edc9_rustbuffer_alloc(
      int32_t size,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_tabs_edc9_rustbuffer_from_bytes(
      ForeignBytes bytes,
    RustCallStatus *_Nonnull out_status
    );
void ffi_tabs_edc9_rustbuffer_free(
      RustBuffer buf,
    RustCallStatus *_Nonnull out_status
    );
RustBuffer ffi_tabs_edc9_rustbuffer_reserve(
      RustBuffer buf,int32_t additional,
    RustCallStatus *_Nonnull out_status
    );
