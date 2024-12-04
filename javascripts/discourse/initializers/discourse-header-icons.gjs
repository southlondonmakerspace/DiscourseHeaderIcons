import { apiInitializer } from "discourse/lib/api";
import dIcon from "discourse-common/helpers/d-icon";

export default apiInitializer("1.34.0", (api) => {
  // Dynamic logic to determine icon and title
  let icon = "calendar";
  let title = "Open status: unknown";

  try {
    const cache = JSON.parse(settings.tool_status);
    const shutter = cache.tools[4];

    if (shutter.status) {
      icon = "calendar-check";
      title = "Open since " + shutter.date;
    } else {
      icon = "calendar-alt";
      title = "Closed since " + shutter.date;
    }
  } catch (e) {
    console.error("Error parsing tool_status settings:", e);
  }

  const site = api.container.lookup("service:site");
  const isMobile = site.mobileView;

  // Add header icons
  api.headerIcons.add(
    "discourse-header-icons",
    <template>
      <li>
        <a
          id="calendar-link"
          class="icon"
          href="/calendar"
          title={{title}}
        >
          {{dIcon icon}}
        </a>
      </li>
    </template>,
    { before: "search" }
  );
});
