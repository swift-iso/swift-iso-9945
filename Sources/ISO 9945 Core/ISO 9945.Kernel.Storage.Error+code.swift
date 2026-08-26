#if !os(Windows)
    extension ISO_9945.Kernel.Storage.Error {

        @inlinable
        public var code: Error.Error.Code {
            switch self {
            case .exhausted:
                return .POSIX.ENOSPC

            case .quota:
                return .POSIX.EDQUOT
            }
        }
    }

    extension ISO_9945.Kernel.Storage.Error {

        @inlinable
        public init?(code: Error.Error.Code) {
            switch code {
            case .POSIX.ENOSPC:
                self = .exhausted

            case _ where Error.Error.Code.POSIX.isEDQUOT(code):
                self = .quota

            default:
                return nil
            }
        }
    }
#endif
