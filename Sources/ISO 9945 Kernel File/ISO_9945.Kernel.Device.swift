#if canImport(ISO_9945_Shims)
    internal import ISO_9945_Shims

    extension ISO_9945.Kernel.Device {

        public var major: Major {
            Major(rawValue: UInt32(iso9945_device_major(rawValue)))
        }

        public var minor: Minor {
            Minor(rawValue: UInt32(iso9945_device_minor(rawValue)))
        }

        internal init(major: UInt32, minor: UInt32) {
            self.init(rawValue: iso9945_device_make(major, minor))
        }
    }

    extension ISO_9945.Kernel.Device {

        public init(major: Major, minor: Minor) {
            self.init(major: major.rawValue, minor: minor.rawValue)
        }
    }

    extension ISO_9945.Kernel.Device: CustomStringConvertible {

        public var description: Swift.String {
            "\(major):\(minor)"
        }
    }
#endif
