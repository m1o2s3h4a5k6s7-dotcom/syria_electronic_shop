buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://googleapis.com") }
    }
}

// 🎯 الكود الحديث الخالي من الأخطاء والتحذيرات ومتوافق مع إغلاق الأقواس بالكامل
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
