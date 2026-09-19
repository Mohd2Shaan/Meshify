plugins {
	kotlin("jvm") version "2.3.21"
	kotlin("plugin.spring") version "2.3.21"
	id("org.springframework.boot") version "4.1.1"
	id("io.spring.dependency-management") version "1.1.7"
	kotlin("plugin.jpa") version "2.3.21"
	id("com.google.protobuf") version "0.10.0"
}

group = "com.emergencymesh"
version = "0.0.1-SNAPSHOT"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(17)
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-h2console")
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-security")
	implementation("org.springframework.boot:spring-boot-starter-validation")
	implementation("org.springframework.boot:spring-boot-starter-webmvc")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("tools.jackson.module:jackson-module-kotlin")
	implementation("com.google.protobuf:protobuf-java:4.36.2")
	// FR-3: libsodium sealed boxes (same library as the app's sodium_libs)
	implementation("com.goterl:lazysodium-java:5.1.4") // 5.2 needs Java 21
	runtimeOnly("com.h2database:h2")
	runtimeOnly("org.postgresql:postgresql")
	testImplementation("org.springframework.boot:spring-boot-starter-data-jpa-test")
	testImplementation("org.springframework.boot:spring-boot-starter-security-test")
	testImplementation("org.springframework.boot:spring-boot-starter-validation-test")
	testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
	testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

kotlin {
	compilerOptions {
		freeCompilerArgs.addAll("-Xjsr305=strict", "-Xannotation-default-target=param-property")
	}
}

// Shared wire format with mesh_app lives in ../proto
sourceSets {
	main {
		proto {
			srcDir("../proto")
		}
	}
}

protobuf {
	protoc {
		artifact = "com.google.protobuf:protoc:4.36.2"
	}
}

allOpen {
	annotation("jakarta.persistence.Entity")
	annotation("jakarta.persistence.MappedSuperclass")
	annotation("jakarta.persistence.Embeddable")
}

tasks.withType<Test> {
	useJUnitPlatform()
}

// KeyGen.kt has its own main(), so name the server's explicitly.
springBoot {
	mainClass.set("com.emergencymesh.EmergencyMeshApplicationKt")
}

// ./gradlew genKeys: creates the backend keypair (FR-3). Private key goes to
// secrets/ (git-ignored); public key goes into the app's source.
tasks.register<JavaExec>("genKeys") {
	group = "emergency mesh"
	description = "Generate the X25519 keypair for sealed-box encryption"
	classpath = sourceSets["main"].runtimeClasspath
	mainClass.set("com.emergencymesh.crypto.KeyGenKt")
	workingDir = projectDir
}
