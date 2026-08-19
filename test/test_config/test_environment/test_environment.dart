/// Test Environment Configuration
enum TestEnvMode { unit, integration, e2e, mock }

class TestEnvironment {
  static TestEnvMode currentMode = TestEnvMode.unit;
  static bool useMockFirebase = true;
  static bool enableNetworkLogging = false;

  static void configureForUnitTesting() {
    currentMode = TestEnvMode.unit;
    useMockFirebase = true;
  }

  static void configureForIntegrationTesting() {
    currentMode = TestEnvMode.integration;
    useMockFirebase = false;
  }
}
