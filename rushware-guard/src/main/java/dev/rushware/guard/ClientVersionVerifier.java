package dev.rushware.guard;

import java.net.InetAddress;
import java.util.UUID;

/**
 * Server-side service for a future trusted launcher verification component.
 * Called synchronously during PlayerLoginEvent, before joining any PGM match.
 */
public interface ClientVersionVerifier {
  /**
   * Consume a short-lived, single-use proof bound to the authenticated UUID and connection address.
   * Return the verified Minecraft version, or null when no valid proof exists.
   * Implementations must not perform network I/O here or trust a client-supplied version string.
   */
  String consumeVerifiedVersion(UUID playerId, InetAddress address);
}
