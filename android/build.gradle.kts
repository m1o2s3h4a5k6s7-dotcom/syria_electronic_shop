buildscript {
    val kotlinVersion = "1.8.22"
    repositories {
        google()
        mavenCentral()
    }
        dependencies {
        // 🎯 قمنا بتحديث رقم الإصدار ليتطابق مع النسخة المخزنة في جهازك تلقائياً
        classpath("com.android.tools.build:gradle:8.11.1") 
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
    }

allprojects {
    repositories {
        google()
        mavenCentral()
        // حقن مستودع فلاتر وتخطي أي حظر تلقائياً
        maven { url = uri("https://googleapis.com") }
    }
}

rootProject.buildDir = layout.buildDirectory.dir("../../build").get().asFile

subprojects {
    project.buildDir = rootProject.buildDir.resolve(project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
