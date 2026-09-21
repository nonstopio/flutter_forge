plugins {
    kotlin("jvm") version "2.4.20"
    jacoco
}

repositories { mavenCentral() }

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.11.0")
    testImplementation(kotlin("test-junit"))
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.11.0")
}

kotlin { jvmToolchain(21) }

sourceSets {
    main {
        kotlin.srcDirs("../../android/src/main/kotlin", "src/fakes/kotlin")
    }
}

jacoco { toolVersion = "0.8.15" }

tasks.test { finalizedBy(tasks.jacocoTestReport) }

val productionClasses = fileTree(layout.buildDirectory.dir("classes/kotlin/main")) {
    include("com/nonstopio/contact/permission/contact_permission/**")
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    classDirectories.setFrom(productionClasses)
    sourceDirectories.setFrom(files("../../android/src/main/kotlin"))
    reports { xml.required = true; html.required = true }
}

tasks.jacocoTestCoverageVerification {
    dependsOn(tasks.jacocoTestReport)
    classDirectories.setFrom(productionClasses)
    violationRules {
        rule { limit { counter = "LINE"; minimum = "1.0".toBigDecimal() } }
    }
}
