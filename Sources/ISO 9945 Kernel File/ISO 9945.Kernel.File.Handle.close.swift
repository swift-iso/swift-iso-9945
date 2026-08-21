extension ISO_9945.Kernel.File.Handle {

    public consuming func close() throws(ISO_9945.Kernel.Close.Error) {
        try ISO_9945.Kernel.Close.close(self.descriptor)
    }
}
