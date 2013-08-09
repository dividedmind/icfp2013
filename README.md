ICFP2013 web service proxy
====

This is a proxy for the ICFP2013 web service.

It's live at http://icfp2013lf.herokuapp.com and has exact same interface as the upstream web service.

Features:
- ~~automatic authorization - I think it's fine as long as we don't publicize the address.~~ 
  - (address is public b/c of irc, use `?auth=<>` as usual)
- throttling
- caching (of problem list, with auto updating when submitting guesses through the proxy)

To be implemented:
- local evaluation
- local problem generation
- sanity checking
- answer memoizing
- IRC bot reporting
- other ideas? Open an issue.
