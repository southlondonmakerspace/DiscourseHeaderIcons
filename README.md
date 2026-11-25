This is the Discourse theme component that puts the Calendar icon and the shutter tick into our Discourse header.

The tick shows whether the space is open. The component reads it from the shutter status route in the SLMS Tool Control Log WordPress plugin (`/wp-json/slms/v1/shutter`), when the page loads, every few minutes, and when the tab comes back into view. If it can't be read, the icon's title says the status is unknown.

Settings:

- `shutter_tick_enable`: turn the tick off, leaving a plain calendar link
- `shutter_status_url`: where to read the status from
- `shutter_refresh_minutes`: how often an open page checks again
