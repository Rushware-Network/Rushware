package dev.rushware.moderation;

import java.util.Arrays;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.bukkit.Bukkit;
import org.bukkit.ChatColor;
import org.bukkit.command.Command;
import org.bukkit.command.CommandSender;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.block.BlockBreakEvent;
import org.bukkit.event.block.BlockPlaceEvent;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.EntityDamageEvent;
import org.bukkit.event.entity.ProjectileLaunchEvent;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerMoveEvent;
import org.bukkit.event.player.AsyncPlayerChatEvent;
import org.bukkit.plugin.java.JavaPlugin;
import tc.oc.pgm.api.integration.Integration;
import tc.oc.pgm.api.integration.PunishmentIntegration;

/** Basic staff tools; player records stay in the ignored runtime folders. */
public final class RushwareModerationPlugin extends JavaPlugin
    implements Listener, PunishmentIntegration {
  private final Map<UUID, String> muted = new ConcurrentHashMap<>();
  private final java.util.Set<UUID> frozen = ConcurrentHashMap.newKeySet();

  @Override
  public void onEnable() {
    reloadConfig();
    var section = getConfig().getConfigurationSection("muted");
    if (section != null) for (String uuid : section.getKeys(false)) {
      muted.put(UUID.fromString(uuid), section.getString(uuid, "Muted by staff"));
    }
    for (String uuid : getConfig().getStringList("frozen")) frozen.add(UUID.fromString(uuid));
    Bukkit.getPluginManager().registerEvents(this, this);
    Integration.setPunishmentIntegration(this);
  }

  @Override
  public boolean isMuted(Player player) { return muted.containsKey(player.getUniqueId()); }

  @Override
  public String getMuteReason(Player player) { return muted.get(player.getUniqueId()); }

  @Override
  public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
    if (args.length < 1) return false;
    String action = command.getName();
    String permission = "pgm." + (action.startsWith("un") ? action.substring(2) : action);
    if (!sender.hasPermission(permission)) {
      sender.sendMessage(ChatColor.RED + "You do not have permission.");
      return true;
    }
    Player target = Bukkit.getPlayerExact(args[0]);
    if (target == null) {
      sender.sendMessage(ChatColor.RED + "Player must be online.");
      return true;
    }
    UUID uuid = target.getUniqueId();
    String reason = args.length > 1 ? String.join(" ", Arrays.copyOfRange(args, 1, args.length))
        : "No reason provided";
    switch (action) {
      case "warn" -> {
        var records = getConfig().getStringList("warnings." + uuid);
        records.add(java.time.Instant.now() + " | " + sender.getName() + " | " + reason);
        getConfig().set("warnings." + uuid, records);
        target.sendMessage(ChatColor.RED + "Staff warning: " + reason);
      }
      case "mute" -> { muted.put(uuid, reason); target.sendMessage(ChatColor.RED + "Muted: " + reason); }
      case "unmute" -> { muted.remove(uuid); target.sendMessage(ChatColor.GREEN + "You are no longer muted."); }
      case "freeze" -> { frozen.add(uuid); target.sendMessage(ChatColor.RED + "You have been frozen by staff."); }
      case "unfreeze" -> { frozen.remove(uuid); target.sendMessage(ChatColor.GREEN + "You are no longer frozen."); }
      default -> { return false; }
    }
    getConfig().set("muted", null);
    muted.forEach((id, text) -> getConfig().set("muted." + id, text));
    getConfig().set("frozen", new java.util.ArrayList<>(frozen.stream().map(UUID::toString).toList()));
    saveConfig();
    getLogger().info(sender.getName() + " used " + action + " on " + target.getName() + ": " + reason);
    sender.sendMessage(ChatColor.GREEN + action + ": " + target.getName());
    return true;
  }

  private boolean isFrozen(Player player) { return frozen.contains(player.getUniqueId()); }

  @EventHandler(ignoreCancelled = true)
  public void onMove(PlayerMoveEvent event) {
    if (isFrozen(event.getPlayer()) && (event.getFrom().getX() != event.getTo().getX()
        || event.getFrom().getY() != event.getTo().getY() || event.getFrom().getZ() != event.getTo().getZ())) {
      event.setTo(event.getFrom());
    }
  }
  @EventHandler(ignoreCancelled = true)
  public void onInteract(PlayerInteractEvent event) { if (isFrozen(event.getPlayer())) event.setCancelled(true); }
  @EventHandler(ignoreCancelled = true)
  public void onBreak(BlockBreakEvent event) { if (isFrozen(event.getPlayer())) event.setCancelled(true); }
  @EventHandler(ignoreCancelled = true)
  public void onPlace(BlockPlaceEvent event) { if (isFrozen(event.getPlayer())) event.setCancelled(true); }
  @EventHandler(ignoreCancelled = true)
  public void onDamage(EntityDamageEvent event) {
    if (event.getEntity() instanceof Player player && isFrozen(player)) event.setCancelled(true);
    if (event instanceof EntityDamageByEntityEvent damage && damage.getDamager() instanceof Player player
        && isFrozen(player)) event.setCancelled(true);
    if (event instanceof EntityDamageByEntityEvent damage
        && damage.getDamager() instanceof org.bukkit.entity.Projectile projectile
        && projectile.getShooter() instanceof Player player && isFrozen(player)) event.setCancelled(true);
  }
  @EventHandler(ignoreCancelled = true)
  public void onLaunch(ProjectileLaunchEvent event) {
    if (event.getEntity().getShooter() instanceof Player player && isFrozen(player)) event.setCancelled(true);
  }
  @EventHandler(ignoreCancelled = true)
  public void onChat(AsyncPlayerChatEvent event) { if (isMuted(event.getPlayer())) event.setCancelled(true); }
}
