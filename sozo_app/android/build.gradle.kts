allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

buildscript {
    val kotlinVersion by extra("1.9.10")
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.google.gms:google-services:4.4.2")
        classpath("com.google.firebase:firebase-appdistribution-gradle:5.0.0")
    }
}
