package com.emergencymesh

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles

@SpringBootTest(properties = ["mesh.crypto.private-key=${ApiIntegrationTests.TEST_PRIVATE_KEY}"])
@ActiveProfiles("dev")
class EmergencyMeshApplicationTests {

	@Test
	fun contextLoads() {
	}

}
