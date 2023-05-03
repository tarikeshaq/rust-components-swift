// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(MozillaRustComponents)
    import MozillaRustComponents
#endif

private extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_tabs_97b9_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_tabs_97b9_rustbuffer_free(self, $0) }
    }
}

private extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a library of its own.

private extension Data {
    init(rustBuffer: RustBuffer) {
        // TODO: This copies the buffer. Can we read directly from a
        // Rust buffer?
        self.init(bytes: rustBuffer.data!, count: Int(rustBuffer.len))
    }
}

// Define reader functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.
//
// With external types, one swift source file needs to be able to call the read
// method on another source file's FfiConverter, but then what visibility
// should Reader have?
// - If Reader is fileprivate, then this means the read() must also
//   be fileprivate, which doesn't work with external types.
// - If Reader is internal/public, we'll get compile errors since both source
//   files will try define the same type.
//
// Instead, the read() method and these helper functions input a tuple of data

private func createReader(data: Data) -> (data: Data, offset: Data.Index) {
    (data: data, offset: 0)
}

// Reads an integer at the current offset, in big-endian order, and advances
// the offset on success. Throws if reading the integer would move the
// offset past the end of the buffer.
private func readInt<T: FixedWidthInteger>(_ reader: inout (data: Data, offset: Data.Index)) throws -> T {
    let range = reader.offset ..< reader.offset + MemoryLayout<T>.size
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    if T.self == UInt8.self {
        let value = reader.data[reader.offset]
        reader.offset += 1
        return value as! T
    }
    var value: T = 0
    let _ = withUnsafeMutableBytes(of: &value) { reader.data.copyBytes(to: $0, from: range) }
    reader.offset = range.upperBound
    return value.bigEndian
}

// Reads an arbitrary number of bytes, to be used to read
// raw bytes, this is useful when lifting strings
private func readBytes(_ reader: inout (data: Data, offset: Data.Index), count: Int) throws -> [UInt8] {
    let range = reader.offset ..< (reader.offset + count)
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    var value = [UInt8](repeating: 0, count: count)
    value.withUnsafeMutableBufferPointer { buffer in
        reader.data.copyBytes(to: buffer, from: range)
    }
    reader.offset = range.upperBound
    return value
}

// Reads a float at the current offset.
private func readFloat(_ reader: inout (data: Data, offset: Data.Index)) throws -> Float {
    return try Float(bitPattern: readInt(&reader))
}

// Reads a float at the current offset.
private func readDouble(_ reader: inout (data: Data, offset: Data.Index)) throws -> Double {
    return try Double(bitPattern: readInt(&reader))
}

// Indicates if the offset has reached the end of the buffer.
private func hasRemaining(_ reader: (data: Data, offset: Data.Index)) -> Bool {
    return reader.offset < reader.data.count
}

// Define writer functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.  See the above discussion on Readers for details.

private func createWriter() -> [UInt8] {
    return []
}

private func writeBytes<S>(_ writer: inout [UInt8], _ byteArr: S) where S: Sequence, S.Element == UInt8 {
    writer.append(contentsOf: byteArr)
}

// Writes an integer in big-endian order.
//
// Warning: make sure what you are trying to write
// is in the correct type!
private func writeInt<T: FixedWidthInteger>(_ writer: inout [UInt8], _ value: T) {
    var value = value.bigEndian
    withUnsafeBytes(of: &value) { writer.append(contentsOf: $0) }
}

private func writeFloat(_ writer: inout [UInt8], _ value: Float) {
    writeInt(&writer, value.bitPattern)
}

private func writeDouble(_ writer: inout [UInt8], _ value: Double) {
    writeInt(&writer, value.bitPattern)
}

// Protocol for types that transfer other types across the FFI. This is
// analogous go the Rust trait of the same name.
private protocol FfiConverter {
    associatedtype FfiType
    associatedtype SwiftType

    static func lift(_ value: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType
    static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType
    static func write(_ value: SwiftType, into buf: inout [UInt8])
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
private protocol FfiConverterPrimitive: FfiConverter where FfiType == SwiftType {}

extension FfiConverterPrimitive {
    public static func lift(_ value: FfiType) throws -> SwiftType {
        return value
    }

    public static func lower(_ value: SwiftType) -> FfiType {
        return value
    }
}

// Types conforming to `FfiConverterRustBuffer` lift and lower into a `RustBuffer`.
// Used for complex types where it's hard to write a custom lift/lower.
private protocol FfiConverterRustBuffer: FfiConverter where FfiType == RustBuffer {}

extension FfiConverterRustBuffer {
    public static func lift(_ buf: RustBuffer) throws -> SwiftType {
        var reader = createReader(data: Data(rustBuffer: buf))
        let value = try read(from: &reader)
        if hasRemaining(reader) {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    public static func lower(_ value: SwiftType) -> RustBuffer {
        var writer = createWriter()
        write(value, into: &writer)
        return RustBuffer(bytes: writer)
    }
}

// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
private enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

private let CALL_SUCCESS: Int8 = 0
private let CALL_ERROR: Int8 = 1
private let CALL_PANIC: Int8 = 2

private extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: {
        $0.deallocate()
        return UniffiInternalError.unexpectedRustCallError
    })
}

private func rustCallWithError<T, F: FfiConverter>
(_ errorFfiConverter: F.Type, _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T
    where F.SwiftType: Error, F.FfiType == RustBuffer
{
    try makeRustCall(callback, errorHandler: { try errorFfiConverter.lift($0) })
}

private func makeRustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T, errorHandler: (RustBuffer) throws -> Error) throws -> T {
    var callStatus = RustCallStatus()
    let returnedVal = callback(&callStatus)
    switch callStatus.code {
    case CALL_SUCCESS:
        return returnedVal

    case CALL_ERROR:
        throw try errorHandler(callStatus.errorBuf)

    case CALL_PANIC:
        // When the rust code sees a panic, it tries to construct a RustBuffer
        // with the message.  But if that code panics, then it just sends back
        // an empty buffer.
        if callStatus.errorBuf.len > 0 {
            throw try UniffiInternalError.rustPanic(FfiConverterString.lift(callStatus.errorBuf))
        } else {
            callStatus.errorBuf.deallocate()
            throw UniffiInternalError.rustPanic("Rust panic")
        }

    default:
        throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

// Public interface members begin here.

private struct FfiConverterInt64: FfiConverterPrimitive {
    typealias FfiType = Int64
    typealias SwiftType = Int64

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> Int64 {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: Int64, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

private struct FfiConverterString: FfiConverter {
    typealias SwiftType = String
    typealias FfiType = RustBuffer

    public static func lift(_ value: RustBuffer) throws -> String {
        defer {
            value.deallocate()
        }
        if value.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: value.data!, count: Int(value.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    public static func lower(_ value: String) -> RustBuffer {
        return value.utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> String {
        let len: Int32 = try readInt(&buf)
        return try String(bytes: readBytes(&buf, count: Int(len)), encoding: String.Encoding.utf8)!
    }

    public static func write(_ value: String, into buf: inout [UInt8]) {
        let len = Int32(value.utf8.count)
        writeInt(&buf, len)
        writeBytes(&buf, value.utf8)
    }
}

public protocol TabsBridgedEngineProtocol {
    func lastSync() throws -> Int64
    func setLastSync(lastSync: Int64) throws
    func syncId() throws -> String?
    func resetSyncId() throws -> String
    func ensureCurrentSyncId(newSyncId: String) throws -> String
    func prepareForSync(clientData: String) throws
    func syncStarted() throws
    func storeIncoming(incomingEnvelopesAsJson: [String]) throws
    func apply() throws -> [String]
    func setUploaded(newTimestamp: Int64, uploadedIds: [TabsGuid]) throws
    func syncFinished() throws
    func reset() throws
    func wipe() throws
}

public class TabsBridgedEngine: TabsBridgedEngineProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    deinit {
        try! rustCall { ffi_tabs_97b9_TabsBridgedEngine_object_free(pointer, $0) }
    }

    public func lastSync() throws -> Int64 {
        return try FfiConverterInt64.lift(
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_last_sync(self.pointer, $0)
            }
        )
    }

    public func setLastSync(lastSync: Int64) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_set_last_sync(self.pointer,
                                                          FfiConverterInt64.lower(lastSync), $0)
            }
    }

    public func syncId() throws -> String? {
        return try FfiConverterOptionString.lift(
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_sync_id(self.pointer, $0)
            }
        )
    }

    public func resetSyncId() throws -> String {
        return try FfiConverterString.lift(
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_reset_sync_id(self.pointer, $0)
            }
        )
    }

    public func ensureCurrentSyncId(newSyncId: String) throws -> String {
        return try FfiConverterString.lift(
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_ensure_current_sync_id(self.pointer,
                                                                   FfiConverterString.lower(newSyncId), $0)
            }
        )
    }

    public func prepareForSync(clientData: String) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_prepare_for_sync(self.pointer,
                                                             FfiConverterString.lower(clientData), $0)
            }
    }

    public func syncStarted() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_sync_started(self.pointer, $0)
            }
    }

    public func storeIncoming(incomingEnvelopesAsJson: [String]) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_store_incoming(self.pointer,
                                                           FfiConverterSequenceString.lower(incomingEnvelopesAsJson), $0)
            }
    }

    public func apply() throws -> [String] {
        return try FfiConverterSequenceString.lift(
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_apply(self.pointer, $0)
            }
        )
    }

    public func setUploaded(newTimestamp: Int64, uploadedIds: [TabsGuid]) throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_set_uploaded(self.pointer,
                                                         FfiConverterInt64.lower(newTimestamp),
                                                         FfiConverterSequenceTypeTabsGuid.lower(uploadedIds), $0)
            }
    }

    public func syncFinished() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_sync_finished(self.pointer, $0)
            }
    }

    public func reset() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_reset(self.pointer, $0)
            }
    }

    public func wipe() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsBridgedEngine_wipe(self.pointer, $0)
            }
    }
}

public struct FfiConverterTypeTabsBridgedEngine: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = TabsBridgedEngine

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> TabsBridgedEngine {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: TabsBridgedEngine, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> TabsBridgedEngine {
        return TabsBridgedEngine(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: TabsBridgedEngine) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}

public protocol TabsStoreProtocol {
    func getAll() -> [ClientRemoteTabs]
    func setLocalTabs(remoteTabs: [RemoteTabRecord])
    func registerWithSyncManager()
    func reset() throws
    func sync(keyId: String, accessToken: String, syncKey: String, tokenserverUrl: String, localId: String) throws -> String
    func bridgedEngine() -> TabsBridgedEngine
}

public class TabsStore: TabsStoreProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    public convenience init(path: String) {
        self.init(unsafeFromRawPointer: try!

            rustCall {
                tabs_97b9_TabsStore_new(
                    FfiConverterString.lower(path), $0
                )
            })
    }

    deinit {
        try! rustCall { ffi_tabs_97b9_TabsStore_object_free(pointer, $0) }
    }

    public func getAll() -> [ClientRemoteTabs] {
        return try! FfiConverterSequenceTypeClientRemoteTabs.lift(
            try!
                rustCall {
                    tabs_97b9_TabsStore_get_all(self.pointer, $0)
                }
        )
    }

    public func setLocalTabs(remoteTabs: [RemoteTabRecord]) {
        try!
            rustCall {
                tabs_97b9_TabsStore_set_local_tabs(self.pointer,
                                                   FfiConverterSequenceTypeRemoteTabRecord.lower(remoteTabs), $0)
            }
    }

    public func registerWithSyncManager() {
        try!
            rustCall {
                tabs_97b9_TabsStore_register_with_sync_manager(self.pointer, $0)
            }
    }

    public func reset() throws {
        try
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsStore_reset(self.pointer, $0)
            }
    }

    public func sync(keyId: String, accessToken: String, syncKey: String, tokenserverUrl: String, localId: String) throws -> String {
        return try FfiConverterString.lift(
            rustCallWithError(FfiConverterTypeTabsApiError.self) {
                tabs_97b9_TabsStore_sync(self.pointer,
                                         FfiConverterString.lower(keyId),
                                         FfiConverterString.lower(accessToken),
                                         FfiConverterString.lower(syncKey),
                                         FfiConverterString.lower(tokenserverUrl),
                                         FfiConverterString.lower(localId), $0)
            }
        )
    }

    public func bridgedEngine() -> TabsBridgedEngine {
        return try! FfiConverterTypeTabsBridgedEngine.lift(
            try!
                rustCall {
                    tabs_97b9_TabsStore_bridged_engine(self.pointer, $0)
                }
        )
    }
}

public struct FfiConverterTypeTabsStore: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = TabsStore

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> TabsStore {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if ptr == nil {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: TabsStore, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> TabsStore {
        return TabsStore(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: TabsStore) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}

public struct ClientRemoteTabs {
    public var clientId: String
    public var clientName: String
    public var deviceType: DeviceType
    public var lastModified: Int64
    public var remoteTabs: [RemoteTabRecord]

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(clientId: String, clientName: String, deviceType: DeviceType, lastModified: Int64, remoteTabs: [RemoteTabRecord]) {
        self.clientId = clientId
        self.clientName = clientName
        self.deviceType = deviceType
        self.lastModified = lastModified
        self.remoteTabs = remoteTabs
    }
}

extension ClientRemoteTabs: Equatable, Hashable {
    public static func == (lhs: ClientRemoteTabs, rhs: ClientRemoteTabs) -> Bool {
        if lhs.clientId != rhs.clientId {
            return false
        }
        if lhs.clientName != rhs.clientName {
            return false
        }
        if lhs.deviceType != rhs.deviceType {
            return false
        }
        if lhs.lastModified != rhs.lastModified {
            return false
        }
        if lhs.remoteTabs != rhs.remoteTabs {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(clientId)
        hasher.combine(clientName)
        hasher.combine(deviceType)
        hasher.combine(lastModified)
        hasher.combine(remoteTabs)
    }
}

public struct FfiConverterTypeClientRemoteTabs: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> ClientRemoteTabs {
        return try ClientRemoteTabs(
            clientId: FfiConverterString.read(from: &buf),
            clientName: FfiConverterString.read(from: &buf),
            deviceType: FfiConverterTypeDeviceType.read(from: &buf),
            lastModified: FfiConverterInt64.read(from: &buf),
            remoteTabs: FfiConverterSequenceTypeRemoteTabRecord.read(from: &buf)
        )
    }

    public static func write(_ value: ClientRemoteTabs, into buf: inout [UInt8]) {
        FfiConverterString.write(value.clientId, into: &buf)
        FfiConverterString.write(value.clientName, into: &buf)
        FfiConverterTypeDeviceType.write(value.deviceType, into: &buf)
        FfiConverterInt64.write(value.lastModified, into: &buf)
        FfiConverterSequenceTypeRemoteTabRecord.write(value.remoteTabs, into: &buf)
    }
}

public func FfiConverterTypeClientRemoteTabs_lift(_ buf: RustBuffer) throws -> ClientRemoteTabs {
    return try FfiConverterTypeClientRemoteTabs.lift(buf)
}

public func FfiConverterTypeClientRemoteTabs_lower(_ value: ClientRemoteTabs) -> RustBuffer {
    return FfiConverterTypeClientRemoteTabs.lower(value)
}

public struct RemoteTabRecord {
    public var title: String
    public var urlHistory: [String]
    public var icon: String?
    public var lastUsed: Int64

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(title: String, urlHistory: [String], icon: String?, lastUsed: Int64) {
        self.title = title
        self.urlHistory = urlHistory
        self.icon = icon
        self.lastUsed = lastUsed
    }
}

extension RemoteTabRecord: Equatable, Hashable {
    public static func == (lhs: RemoteTabRecord, rhs: RemoteTabRecord) -> Bool {
        if lhs.title != rhs.title {
            return false
        }
        if lhs.urlHistory != rhs.urlHistory {
            return false
        }
        if lhs.icon != rhs.icon {
            return false
        }
        if lhs.lastUsed != rhs.lastUsed {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(urlHistory)
        hasher.combine(icon)
        hasher.combine(lastUsed)
    }
}

public struct FfiConverterTypeRemoteTabRecord: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> RemoteTabRecord {
        return try RemoteTabRecord(
            title: FfiConverterString.read(from: &buf),
            urlHistory: FfiConverterSequenceString.read(from: &buf),
            icon: FfiConverterOptionString.read(from: &buf),
            lastUsed: FfiConverterInt64.read(from: &buf)
        )
    }

    public static func write(_ value: RemoteTabRecord, into buf: inout [UInt8]) {
        FfiConverterString.write(value.title, into: &buf)
        FfiConverterSequenceString.write(value.urlHistory, into: &buf)
        FfiConverterOptionString.write(value.icon, into: &buf)
        FfiConverterInt64.write(value.lastUsed, into: &buf)
    }
}

public func FfiConverterTypeRemoteTabRecord_lift(_ buf: RustBuffer) throws -> RemoteTabRecord {
    return try FfiConverterTypeRemoteTabRecord.lift(buf)
}

public func FfiConverterTypeRemoteTabRecord_lower(_ value: RemoteTabRecord) -> RustBuffer {
    return FfiConverterTypeRemoteTabRecord.lower(value)
}

public enum TabsApiError {
    case SyncError(reason: String)
    case SqlError(reason: String)
    case UnexpectedTabsError(reason: String)
}

public struct FfiConverterTypeTabsApiError: FfiConverterRustBuffer {
    typealias SwiftType = TabsApiError

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> TabsApiError {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        case 1: return try .SyncError(
                reason: FfiConverterString.read(from: &buf)
            )
        case 2: return try .SqlError(
                reason: FfiConverterString.read(from: &buf)
            )
        case 3: return try .UnexpectedTabsError(
                reason: FfiConverterString.read(from: &buf)
            )

        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: TabsApiError, into buf: inout [UInt8]) {
        switch value {
        case let .SyncError(reason):
            writeInt(&buf, Int32(1))
            FfiConverterString.write(reason, into: &buf)

        case let .SqlError(reason):
            writeInt(&buf, Int32(2))
            FfiConverterString.write(reason, into: &buf)

        case let .UnexpectedTabsError(reason):
            writeInt(&buf, Int32(3))
            FfiConverterString.write(reason, into: &buf)
        }
    }
}

extension TabsApiError: Equatable, Hashable {}

extension TabsApiError: Error {}

private struct FfiConverterOptionString: FfiConverterRustBuffer {
    typealias SwiftType = String?

    public static func write(_ value: SwiftType, into buf: inout [UInt8]) {
        guard let value = value else {
            writeInt(&buf, Int8(0))
            return
        }
        writeInt(&buf, Int8(1))
        FfiConverterString.write(value, into: &buf)
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType {
        switch try readInt(&buf) as Int8 {
        case 0: return nil
        case 1: return try FfiConverterString.read(from: &buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }
}

private struct FfiConverterSequenceString: FfiConverterRustBuffer {
    typealias SwiftType = [String]

    public static func write(_ value: [String], into buf: inout [UInt8]) {
        let len = Int32(value.count)
        writeInt(&buf, len)
        for item in value {
            FfiConverterString.write(item, into: &buf)
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> [String] {
        let len: Int32 = try readInt(&buf)
        var seq = [String]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            try seq.append(FfiConverterString.read(from: &buf))
        }
        return seq
    }
}

private struct FfiConverterSequenceTypeClientRemoteTabs: FfiConverterRustBuffer {
    typealias SwiftType = [ClientRemoteTabs]

    public static func write(_ value: [ClientRemoteTabs], into buf: inout [UInt8]) {
        let len = Int32(value.count)
        writeInt(&buf, len)
        for item in value {
            FfiConverterTypeClientRemoteTabs.write(item, into: &buf)
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> [ClientRemoteTabs] {
        let len: Int32 = try readInt(&buf)
        var seq = [ClientRemoteTabs]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            try seq.append(FfiConverterTypeClientRemoteTabs.read(from: &buf))
        }
        return seq
    }
}

private struct FfiConverterSequenceTypeRemoteTabRecord: FfiConverterRustBuffer {
    typealias SwiftType = [RemoteTabRecord]

    public static func write(_ value: [RemoteTabRecord], into buf: inout [UInt8]) {
        let len = Int32(value.count)
        writeInt(&buf, len)
        for item in value {
            FfiConverterTypeRemoteTabRecord.write(item, into: &buf)
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> [RemoteTabRecord] {
        let len: Int32 = try readInt(&buf)
        var seq = [RemoteTabRecord]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            try seq.append(FfiConverterTypeRemoteTabRecord.read(from: &buf))
        }
        return seq
    }
}

private struct FfiConverterSequenceTypeTabsGuid: FfiConverterRustBuffer {
    typealias SwiftType = [TabsGuid]

    public static func write(_ value: [TabsGuid], into buf: inout [UInt8]) {
        let len = Int32(value.count)
        writeInt(&buf, len)
        for item in value {
            FfiConverterTypeTabsGuid.write(item, into: &buf)
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> [TabsGuid] {
        let len: Int32 = try readInt(&buf)
        var seq = [TabsGuid]()
        seq.reserveCapacity(Int(len))
        for _ in 0 ..< len {
            try seq.append(FfiConverterTypeTabsGuid.read(from: &buf))
        }
        return seq
    }
}

/**
 * Typealias from the type name used in the UDL file to the builtin type.  This
 * is needed because the UDL type name is used in function/method signatures.
 */
public typealias TabsGuid = String
public struct FfiConverterTypeTabsGuid: FfiConverter {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> TabsGuid {
        return try FfiConverterString.read(from: &buf)
    }

    public static func write(_ value: TabsGuid, into buf: inout [UInt8]) {
        return FfiConverterString.write(value, into: &buf)
    }

    public static func lift(_ value: RustBuffer) throws -> TabsGuid {
        return try FfiConverterString.lift(value)
    }

    public static func lower(_ value: TabsGuid) -> RustBuffer {
        return FfiConverterString.lower(value)
    }
}

/**
 * Top level initializers and tear down methods.
 *
 * This is generated by uniffi.
 */
public enum TabsLifecycle {
    /**
     * Initialize the FFI and Rust library. This should be only called once per application.
     */
    func initialize() {}
}
