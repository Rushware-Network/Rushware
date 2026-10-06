plugins {
    `java-library`
}

group = "dev.rushware"
version = "0.1.0-SNAPSHOT"
java.toolchain.languageVersion = JavaLanguageVersion.of(25)

repositories {
    mavenCentral()
    maven("https://repo.pgm.fyi/snapshots")
}

dependencies {
    compileOnly("app.ashcon:sportpaper:1.8.8-R0.1-20260415.185524-1")
    testImplementation("org.junit.jupiter:junit-jupiter:6.1.3")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.withType<JavaCompile>().configureEach { options.encoding = "UTF-8" }
tasks.test { useJUnitPlatform() }
tasks.jar {
    archiveFileName = "RushwareGuard.jar"
    destinationDirectory = rootProject.layout.projectDirectory.dir("build/libs")
}
