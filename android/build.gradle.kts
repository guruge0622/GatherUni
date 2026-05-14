buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
}

import org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension
import org.gradle.jvm.toolchain.JavaLanguageVersion
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.gradle.api.JavaVersion

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

// (Removed root-level kotlinOptions configuration due to Kotlin Gradle API changes.)

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Configure Kotlin JVM toolchain to Java 17 for all Kotlin-enabled subprojects.
subprojects {
    plugins.withType(org.jetbrains.kotlin.gradle.plugin.KotlinBasePluginWrapper::class.java) {
        val kotlinExt = extensions.findByType(org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension::class.java)
        kotlinExt?.jvmToolchain {
            languageVersion.set(JavaLanguageVersion.of(17))
        }
    }
}

// Ensure Kotlin compile tasks target JVM 17 to match Java compileOptions.
subprojects {
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        try {
            // Try new Kotlin compilerOptions API: compilerOptions.jvmTarget (accepts JavaLanguageVersion or String)
            val compilerOptions = try {
                this::class.java.getMethod("getCompilerOptions").invoke(this)
            } catch (e: NoSuchMethodException) {
                null
            }
            if (compilerOptions != null) {
                try {
                    // Try setter that accepts JavaLanguageVersion
                    compilerOptions::class.java.getMethod("setJvmTarget", org.gradle.jvm.toolchain.JavaLanguageVersion::class.java)
                        .invoke(compilerOptions, JavaLanguageVersion.of(17))
                } catch (_: NoSuchMethodException) {
                    try {
                        // Fallback to String jvmTarget setter
                        compilerOptions::class.java.getMethod("setJvmTarget", String::class.java)
                            .invoke(compilerOptions, JavaVersion.VERSION_17.toString())
                    } catch (_: Throwable) {
                    }
                }
            } else {
                // Fallback for older Kotlin plugin: kotlinOptions.jvmTarget
                try {
                    val kotlinOptions = this::class.java.getMethod("getKotlinOptions").invoke(this)
                    kotlinOptions::class.java.getMethod("setJvmTarget", String::class.java)
                        .invoke(kotlinOptions, JavaVersion.VERSION_17.toString())
                } catch (_: Throwable) {
                }
            }
        } catch (_: Throwable) {
            // Best-effort; ignore any reflection errors.
        }
    }
}
