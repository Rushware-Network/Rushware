package dev.rushware.guard;

import java.net.InetAddress;

/** No protocol-only fallback: protocol 47 is shared by all released Java 1.8 clients. */
public final class AdmissionPolicy {
  private AdmissionPolicy() {}

  public static boolean permits(int protocol, String verifiedVersion) {
    return protocol == 47 && "1.8.9".equals(verifiedVersion);
  }

  /** Explicit local gameplay testing only; this does not verify the exact client release. */
  public static boolean permitsLocalTest(int protocol, InetAddress address, String serverIp) {
    return protocol == 47 && address != null && address.isLoopbackAddress()
        && ("127.0.0.1".equals(serverIp) || "::1".equals(serverIp));
  }
}
