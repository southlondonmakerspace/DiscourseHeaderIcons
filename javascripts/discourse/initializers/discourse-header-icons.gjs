import { tracked } from "@glimmer/tracking";
import { apiInitializer } from "discourse/lib/api";
import dIcon from "discourse/helpers/d-icon";

// Whether the space is open, read from the shutter status on the WordPress site:
// {"status": "open" | "closed" | "unknown", "since": ISO 8601 or null}
class Shutter {
  @tracked open = null; // true, false, or null when not known
  @tracked since = null;

  get icon() {
    return this.open ? "calendar-check" : "calendar-days";
  }

  get title() {
    if (!settings.shutter_tick_enable) {
      return "Calendar";
    }
    if (this.open === null) {
      return "Open status: unknown";
    }
    const when = this.since
      ? new Date(this.since).toLocaleString([], {
          day: "numeric",
          month: "short",
          hour: "2-digit",
          minute: "2-digit",
        })
      : "";
    return (this.open ? "Open" : "Closed") + (when ? ` since ${when}` : "");
  }

  async refresh() {
    if (document.hidden) {
      return; // no need to check while the tab isn't being looked at
    }
    try {
      const res = await fetch(settings.shutter_status_url, {
        headers: { Accept: "application/json" },
      });
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}`);
      }
      const data = await res.json();
      this.open =
        data.status === "open" ? true : data.status === "closed" ? false : null;
      this.since = this.open === null ? null : data.since || null;
    } catch (e) {
      this.open = null;
      this.since = null;
      // eslint-disable-next-line no-console
      console.warn("Shutter status:", e);
    }
  }
}

export default apiInitializer("1.34.0", (api) => {
  const shutter = new Shutter();

  if (settings.shutter_tick_enable && settings.shutter_status_url) {
    shutter.refresh();
    setInterval(
      () => shutter.refresh(),
      settings.shutter_refresh_minutes * 60 * 1000
    );
    document.addEventListener("visibilitychange", () => shutter.refresh());
  }

  api.headerIcons.add(
    "discourse-header-icons",
    <template>
      <li>
        <a
          id="calendar-link"
          class="icon"
          href="/calendar"
          title={{shutter.title}}
        >
          {{dIcon shutter.icon}}
        </a>
      </li>
    </template>,
    { before: "search" }
  );
});
