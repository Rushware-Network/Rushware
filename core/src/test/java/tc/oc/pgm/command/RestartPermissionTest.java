package tc.oc.pgm.command;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import java.util.Arrays;
import org.incendo.cloud.annotations.Command;
import org.incendo.cloud.annotations.Permission;
import org.junit.jupiter.api.Test;
import tc.oc.pgm.api.Permissions;

class RestartPermissionTest {
  @Test
  void endingMatchesDoesNotGrantServerRestartAccess() {
    assertNotEquals(Permissions.STOP, Permissions.RESTART);
    assertEquals(Permissions.STOP, permission(FinishCommand.class, "end"));
    assertEquals(Permissions.STOP, permission(CancelCommand.class, "cancel"));
    assertEquals(Permissions.RESTART, permission(RestartCommand.class, "restart"));
  }

  @Test
  void cyclingMapsDoesNotRequireStartingMatches() {
    assertNotEquals(Permissions.START, Permissions.CYCLE);
    assertEquals(Permissions.CYCLE, permission(CycleCommand.class, "cycle"));
    assertEquals(Permissions.CYCLE, permission(CycleCommand.class, "recycle"));
    assertEquals(Boolean.TRUE, Permissions.MODERATOR.getChildren().get(Permissions.CYCLE));
    assertEquals(
        "finish|end [team]",
        Arrays.stream(FinishCommand.class.getDeclaredMethods())
            .filter(method -> method.getName().equals("end"))
            .findFirst()
            .orElseThrow()
            .getAnnotation(Command.class)
            .value());
  }

  private String permission(Class<?> command, String methodName) {
    return Arrays.stream(command.getDeclaredMethods())
        .filter(method -> method.getName().equals(methodName))
        .findFirst()
        .orElseThrow()
        .getAnnotation(Permission.class)
        .value()[0];
  }
}
