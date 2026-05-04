// Re-export the test-support spine. Cardinal Primitives Test Support
// transitively re-exports Tagged Primitives Test Support, which carries
// the Tagged ExpressibleBy*Literal conformances. Test files importing
// `ISO_9945_Kernel_Test_Support` get the SLI conformances under
// MemberImportVisibility without needing per-file SLI imports.
@_exported public import Cardinal_Primitives_Test_Support
