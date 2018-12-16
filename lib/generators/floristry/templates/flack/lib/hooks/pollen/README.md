# pollen
Pollen provides the capability for an external application to observe
Flor's behaviors using an HTTP interface. It's also a great showcase
for Flor's hooking facility (see [hooks.conf.sample](hooks.conf.sample)).

By default it will report the following events but those can be extended:

1. flow creation/launch
2. task return (aka reply and proceed)
3. flow termination
4. cancellation
5. errors

## Instructions
1. Clone the repository within Flor's `lib/hooks` directory.
2. Copy the content of `hooks.json.sample` on Flor's
   `lib/hooks/hooks.json` to inform Flor about the new hooks.
   This is where you can extend the events you want to monitor.
3. By default Pollen will contact your hook handler at
   `http://localhost:3000/hookhandler/`. This can be controlled through
   your Flor configuration (`<env>/etc/conf.json`) as follow:
   ```
   pollen_prot: "http"
   pollen_host: "localhost"
   pollen_port: "3000"
   pollen_path: "hookhandler"
   ```
4. Enjoy!

## License
MIT, see [LICENSE.md](LICENSE.md)
