internal import Cardinal

extension ISO_9945.Kernel.File.System {

    public enum Name {}
}

extension ISO_9945.Kernel.File.System.Name {

    public typealias Length = Tagged<ISO_9945.Kernel.File.System.Name, Cardinal>
}
