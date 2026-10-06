package dev.rushware.guard;

import java.net.InetAddress;

/** Strict admission and explicitly enabled test exceptions for the shared 1.8 protocol. */
public final class AdmissionPolicy {
  private AdmissionPolicy() {}

  public static boolean permits(int protocol, String verifiedVersion) {
    return protocol == 47 && "1.8.9".equals(verifiedVersion);
  }

  /** Remote testing still requires online authentication and an enabled whitelist. */
  public static boolean permitsRemoteTest(
      int protocol, boolean onlineMode, boolean whitelistEnabled, boolean whitelisted) {
    return protocol == 47 && onlineMode && whitelistEnabled && whitelisted;
  }

  /** Explicit local gameplay testing only; this does not verify the exact client release. */
  public static boolean permitsLocalTest(int protocol, InetAddress address, String serverIp) {
    return protocol == 47 && address != null && address.isLoopbackAddress()
        && ("127.0.0.1".equals(serverIp) || "::1".equals(serverIp));
  }
}
