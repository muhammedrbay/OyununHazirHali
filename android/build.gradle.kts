buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.3.15") // ✅ Firebase plugin
    }

    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build output yolu düzenlemesi (opsiyonel ama derli toplu yapı için iyi)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// Temizlik görevi
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

