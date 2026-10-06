package dev.rushware.guard;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.net.InetAddress;
import org.junit.jupiter.api.Test;

class AdmissionPolicyTest {
  @Test
  void remoteTestRequiresAuthenticationWhitelistAndProtocol47() {
    assertTrue(AdmissionPolicy.permitsRemoteTest(47, true, true, true));
    assertFalse(AdmissionPolicy.permitsRemoteTest(47, false, true, true));
    assertFalse(AdmissionPolicy.permitsRemoteTest(47, true, false, true));
    assertFalse(AdmissionPolicy.permitsRemoteTest(47, true, true, false));
    for (int protocol : new int[] {-1, 5, 46, 48, 107, 776}) {
      assertFalse(AdmissionPolicy.permitsRemoteTest(protocol, true, true, true));
    }
  }

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

  @Test
  void localTestRequiresLoopbackConnectionAndLoopbackBind() throws Exception {
    var loopback = InetAddress.getByName("127.0.0.1");
    assertTrue(AdmissionPolicy.permitsLocalTest(47, loopback, "127.0.0.1"));
    assertTrue(AdmissionPolicy.permitsLocalTest(47, InetAddress.getByName("::1"), "::1"));
    assertFalse(AdmissionPolicy.permitsLocalTest(47, loopback, "0.0.0.0"));
    assertFalse(AdmissionPolicy.permitsLocalTest(47, loopback, ""));
    assertFalse(AdmissionPolicy.permitsLocalTest(47, InetAddress.getByName("192.168.1.2"), "127.0.0.1"));
    assertFalse(AdmissionPolicy.permitsLocalTest(47, null, "127.0.0.1"));
    assertFalse(AdmissionPolicy.permitsLocalTest(107, loopback, "127.0.0.1"));
    assertFalse(AdmissionPolicy.permits(47, null));
  }
}
