allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Force subprojects to avoid JCenter
subprojects {
    repositories {
        google()
        mavenCentral()
        removeIf { it is MavenArtifactRepository && it.url.toString().contains("jcenter") }
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

subprojects {
    plugins.withId("com.android.library") {
        val android = project.extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android.namespace == null) {
            android.namespace = if (project.name == "ar_flutter_plugin" || project.name == "ar_flutter_plugin_updated") {
                "io.github.isvisoft.ar_flutter_plugin"
            } else {
                project.group.toString()
            }
        }
    }
    plugins.withId("com.android.application") {
        val android = project.extensions.getByType(com.android.build.gradle.AppExtension::class.java)
        if (android.namespace == null) {
            android.namespace = project.group.toString()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
