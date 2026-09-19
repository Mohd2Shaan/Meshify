package com.emergencymesh

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class EmergencyMeshApplication

fun main(args: Array<String>) {
	runApplication<EmergencyMeshApplication>(*args)
}
