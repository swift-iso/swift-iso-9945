extension Memory.Lock {

    public static func lockAll(_ flags: All.Options) throws(Error) {
        try lockAll(flags: flags.rawValue)
    }
}
