ICFP2013 web service proxy
====

This is a proxy for the ICFP2013 web service.

It's live at http://icfp2013lf.herokuapp.com and has exact same interface as the upstream web service.

Features:
- ~~automatic authorization - I think it's fine as long as we don't publicize the address.~~ 
  - (address is public b/c of irc, use `?auth=<>` as usual)
- throttling

To be implemented:
- local problem generation
- caching
- sanity checking
- IRC bot reporting
- other ideas? Open an issue.
