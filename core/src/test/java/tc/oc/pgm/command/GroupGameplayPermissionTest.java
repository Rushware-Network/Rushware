package tc.oc.pgm.command;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.google.gson.JsonParser;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import org.bukkit.configuration.file.YamlConfiguration;
import org.junit.jupiter.api.Test;
import tc.oc.pgm.api.Permissions;

class GroupGameplayPermissionTest {
  @Test
  void adminCanEndAndCycleWhileParticipatingWithoutStartingMatches() throws Exception {
    var template = Path.of(System.getProperty("rushware.groupPolicy"))
        .resolveSibling("rushware-pgm-groups.yml");
    var config = new YamlConfiguration();
    config.loadFromString("groups:\n" + Files.readString(template));
    for (String state : List.of("observer", "participant")) {
      var permissions = config.getStringList("groups.admin." + state + "-permissions");
      assertTrue(permissions.contains("+" + Permissions.STOP));
      assertTrue(permissions.contains("+" + Permissions.CYCLE));
      assertFalse(permissions.contains("+" + Permissions.RESTART));
    }
    assertTrue(config
        .getStringList("groups.admin.participant-permissions")
        .contains("-" + Permissions.START));
  }

  @Test
  void deploymentGroupsDoNotDenyParentsOfOrdinaryGameplayPermissions() throws Exception {
    var groups = JsonParser.parseString(
            Files.readString(Path.of(System.getProperty("rushware.groupPolicy"))))
        .getAsJsonObject()
        .getAsJsonObject("groups");
    var parents = Map.of(
        Permissions.DEFAULT.getName(), Permissions.DEFAULT,
        Permissions.PREMIUM.getName(), Permissions.PREMIUM,
        Permissions.MODERATOR.getName(), Permissions.MODERATOR,
        Permissions.DEVELOPER.getName(), Permissions.DEVELOPER,
        Permissions.ALL.getName(), Permissions.ALL);
    for (var group : groups.entrySet()) {
      for (var element : group.getValue().getAsJsonObject().getAsJsonArray("nodes")) {
        var node = element.getAsJsonObject();
        if (node.get("value").getAsBoolean()) continue;
        var key = node.get("key").getAsString();
        for (String basic :
            List.of(Permissions.JOIN, Permissions.LEAVE, Permissions.VIEW_INVENTORY)) {
          assertFalse(
              key.equals(basic)
                  || (parents.containsKey(key)
                      && Boolean.TRUE.equals(parents.get(key).getChildren().get(basic))),
              () -> group.getKey() + " denies ordinary gameplay through " + key + ": " + basic);
        }
      }
    }
  }
}
