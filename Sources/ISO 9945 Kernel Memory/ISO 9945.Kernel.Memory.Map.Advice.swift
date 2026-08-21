#if !os(Windows)

    import Memory_Primitives

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension Memory.Map.Advice {

        public static var normal: Self {
            Self(rawValue: MADV_NORMAL)
        }

        public static var sequential: Self {
            Self(rawValue: MADV_SEQUENTIAL)
        }

        public static var random: Self {
            Self(rawValue: MADV_RANDOM)
        }

        public static var willNeed: Self {
            Self(rawValue: MADV_WILLNEED)
        }

        public static var dontNeed: Self {
            Self(rawValue: MADV_DONTNEED)
        }
    }

    #if canImport(Darwin)

        extension Memory.Map.Advice {

            public static var free: Self {
                Self(rawValue: MADV_FREE)
            }

            public static var zeroWiredPages: Self {
                Self(rawValue: MADV_ZERO_WIRED_PAGES)
            }
        }
    #endif

    #if canImport(Glibc) || canImport(Musl)

        extension Memory.Map.Advice {

            public static var remove: Self {
                Self(rawValue: MADV_REMOVE)
            }

            public static var dontDump: Self {
                Self(rawValue: MADV_DONTDUMP)
            }

            public static var doDump: Self {
                Self(rawValue: MADV_DODUMP)
            }

            public static var hugePage: Self {
                Self(rawValue: MADV_HUGEPAGE)
            }

            public static var noHugePage: Self {
                Self(rawValue: MADV_NOHUGEPAGE)
            }
        }
    #endif

#endif
