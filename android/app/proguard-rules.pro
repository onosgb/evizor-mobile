# Flutter/Android R8 ProGuard rules for evizor_app

# ── Ktor / JVM-only classes ──────────────────────────────────────────────────
# Ktor's IntellijIdeaDebugDetector references java.lang.management classes
# which exist on the JVM but NOT on Android. Suppress these warnings so
# R8 doesn't fail the release build.
-dontwarn java.lang.management.ManagementFactory
-dontwarn java.lang.management.RuntimeMXBean
