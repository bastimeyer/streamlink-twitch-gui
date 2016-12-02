[<%= display_name %>](<%= homepage %>)
===

### Release highlights (v<%= version %>)

<%= changelog %> / [Wiki](https://github.com/streamlink/streamlink-twitch-gui/wiki) / [Installation instructions](https://github.com/streamlink/streamlink-twitch-gui/wiki/Installation) / [Open issues](https://github.com/streamlink/streamlink-twitch-gui/issues) / [Chat](https://gitter.com/streamlink/streamlink-twitch-gui)

<% if ( donation && donation.length ) { %>
### Donate

If you think that this application is helpful, please consider supporting the creator by donating.
Thank you very much!

<% donation.forEach(function( item ) { %>* [<%= item.text %>](<%= item.url %>)<% if ( item.coinaddress ) { %> (`<%= item.coinaddress %>`)<% } %>
<% }) %>
<% } %>