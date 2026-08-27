#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    public import Loader_Vocabulary
    import String
    public import ISO_9945_Core

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Loader.Error {

        @usableFromInline
        internal static func captureError() -> Loader.Message {
            if let cstr = unsafe dlerror() {
                let u8Ptr = unsafe UnsafePointer<UInt8>(cstr)
                let view = unsafe String.String.Borrowed(
                    u8Ptr,
                    count: String.String.length(of: u8Ptr)
                )
                return unsafe Loader.Message(copying: view)
            }

            return Loader.Message(ascii: "unknown error")
        }
    }
#endif
