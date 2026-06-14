allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ── Namespace compatibility shim ─────────────────────────────────────────────
// AGP 8+ requires every library to declare a `namespace` in its build.gradle.
// Many older pub.dev packages omit this field. The block below reads the
// `package` attribute from each library's AndroidManifest.xml and injects it
// as the namespace at evaluation time, so we don't have to patch pub cache.
subprojects {
    val configureNamespace = Action<Project> {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            if (namespace == null) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    try {
                        val pkg = javax.xml.parsers.DocumentBuilderFactory
                            .newInstance()
                            .newDocumentBuilder()
                            .parse(manifestFile)
                            .documentElement
                            .getAttribute("package")
                        if (pkg.isNotEmpty()) namespace = pkg
                    } catch (_: Exception) { /* manifest unreadable – skip */ }
                }
            }
        }
    }

    if (state.executed) {
        configureNamespace.execute(this)
    } else {
        afterEvaluate(configureNamespace)
    }
}

