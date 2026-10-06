package tc.oc.pgm.command;

import static org.junit.jupiter.api.Assertions.assertFalse;

import com.google.gson.JsonParser;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import tc.oc.pgm.api.Permissions;

class GroupGameplayPermissionTest {
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
