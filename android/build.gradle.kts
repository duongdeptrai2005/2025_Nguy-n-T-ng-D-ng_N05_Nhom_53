plugins {
    // Plugin Google Services cần được apply ở cấp app, nên để apply false ở đây là đúng
    id("com.google.gms.google-services") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.application")) {
            // ✅ Firebase plugin phải được apply đúng thứ tự
            apply(plugin = "com.google.gms.google-services")
        }
    }
}

// ✅ Không cần chỉnh dòng này, chỉ giữ nguyên
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
