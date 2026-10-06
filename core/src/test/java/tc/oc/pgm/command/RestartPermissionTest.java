package tc.oc.pgm.command;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import java.util.Arrays;
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

  private String permission(Class<?> command, String methodName) {
    return Arrays.stream(command.getDeclaredMethods())
        .filter(method -> method.getName().equals(methodName))
        .findFirst()
        .orElseThrow()
        .getAnnotation(Permission.class)
        .value()[0];
  }
}
