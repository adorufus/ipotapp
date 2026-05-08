import com.android.build.gradle.LibraryExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Workaround for older plugins (e.g. qr_code_scanner 1.0.1) that don't declare
// `android.namespace`, which is required by Android Gradle Plugin 8+.
//
// This avoids editing Pub cache files under:
// C:\Users\<you>\AppData\Local\Pub\Cache\...

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        // Apply only to qr_code_scanner to minimize risk.
        if (name == "qr_code_scanner") {
            extensions.findByType(LibraryExtension::class.java)?.let { androidExt ->
                // `namespace` is a non-null var in AGP APIs, but may be empty.
                val currentNs = androidExt.namespace
                if (currentNs.isNullOrBlank()) {
                    androidExt.namespace = "net.touchcapture.qr.flutterqr"
                }
            }

            // qr_code_scanner 1.0.1 compiles Java at 1.8; ensure Kotlin matches.
            tasks.withType(KotlinCompile::class.java).configureEach {
                compilerOptions.jvmTarget.set(JvmTarget.JVM_1_8)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
