package dev.rushware.guard;

/** No protocol-only fallback: protocol 47 is shared by all released Java 1.8 clients. */
public final class AdmissionPolicy {
  private AdmissionPolicy() {}

  public static boolean permits(int protocol, String verifiedVersion) {
    return protocol == 47 && "1.8.9".equals(verifiedVersion);
  }
}
