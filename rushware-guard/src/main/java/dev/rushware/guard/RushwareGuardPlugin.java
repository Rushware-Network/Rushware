package dev.rushware.guard;

import java.util.List;
import java.util.logging.Level;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerLoginEvent;
import org.bukkit.plugin.java.JavaPlugin;

public final class RushwareGuardPlugin extends JavaPlugin implements Listener {
  private boolean localTest;
  private static final List<String> TRANSLATORS =
      List.of("ViaVersion", "ViaBackwards", "ViaRewind", "ProtocolSupport");

  @Override
  public void onEnable() {
    saveDefaultConfig();
    localTest = getConfig().getBoolean("local-test", false);
    getServer().getPluginManager().registerEvents(this, this);
    getLogger().warning(localTest
        ? "LOCAL TEST MODE: permits loopback protocol-47 clients, including other 1.8.x releases. This is not strict 1.8.9 verification."
        : "Strict 1.8.9 admission enabled. Without a trusted ClientVersionVerifier, all logins are denied.");
  }

  @EventHandler(priority = EventPriority.HIGHEST)
  public void onLogin(PlayerLoginEvent event) {
    // Preserve bans, whitelist restrictions and other earlier denials.
    if (event.getResult() != PlayerLoginEvent.Result.ALLOWED) return;

    var plugins = getServer().getPluginManager();
    // This SportPaper build inherits the CraftBukkit name, so check its implementation instead.
    boolean nativeServer = isNativeSportPaper()
        && getServer().getBukkitVersion().startsWith("1.8.8-");
    if (!nativeServer || !getServer().getOnlineMode() || !plugins.isPluginEnabled("PGM")
        || TRANSLATORS.stream().anyMatch(name -> plugins.getPlugin(name) != null)) {
      deny(event, "Rushware server configuration is not ready for strict 1.8.9 admission.");
      return;
    }

    try {
      int protocol = event.getPlayer().getProtocolVersion();
      if (localTest && AdmissionPolicy.permitsLocalTest(
          protocol, event.getAddress(), getServer().getIp())) return;
      var verifier = getServer().getServicesManager().load(ClientVersionVerifier.class);
      String version = protocol == 47 && verifier != null
          ? verifier.consumeVerifiedVersion(event.getPlayer().getUniqueId(), event.getAddress())
          : null;
      if (!AdmissionPolicy.permits(protocol, version)) {
        deny(event, "Rushware requires verified Minecraft Java 1.8.9. Launcher verification is not available yet.");
      }
    } catch (Throwable failure) {
      // Includes absent native protocol API and a broken verification provider: never fail open.
      getLogger().log(Level.SEVERE, "Client version verification failed", failure);
      deny(event, "Rushware could not verify your Minecraft Java 1.8.9 client.");
    }
  }

  private boolean isNativeSportPaper() {
    if (!getServer().getClass().getName().equals("org.bukkit.craftbukkit.v1_8_R3.CraftServer")) {
      return false;
    }
    try {
      Class.forName("app.ashcon.sportpaper.server.WorldGenSettingsManager", false,
          getServer().getClass().getClassLoader());
      return true;
    } catch (ClassNotFoundException | LinkageError failure) {
      return false;
    }
  }

  private static void deny(PlayerLoginEvent event, String message) {
    event.disallow(PlayerLoginEvent.Result.KICK_OTHER, message);
  }
}
