package dev.rushware.guard;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class AdmissionPolicyTest {
  @Test
  void requiresExactVerifiedVersionEvenForSharedProtocol() {
    assertTrue(AdmissionPolicy.permits(47, "1.8.9"));
    for (String version : new String[] {"1.8", "1.8.8", "1.9", "1.8.9-forge", "", null}) {
      assertFalse(AdmissionPolicy.permits(47, version));
    }
  }

  @Test
  void rejectsOtherProtocolsEvenWithVersionProof() {
    for (int protocol : new int[] {-1, 5, 46, 48, 107, 776}) {
      assertFalse(AdmissionPolicy.permits(protocol, "1.8.9"));
    }
  }
}
