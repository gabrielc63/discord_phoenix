# DiscordClone

## Phoenix LiveView Chat Application

A real-time chat application built with Phoenix LiveView, inspired by Discord's UI. This application demonstrates the power of Phoenix LiveView for building interactive, real-time web applications without writing any JavaScript.

## Features

- Real-time message updates using Phoenix PubSub
- Multiple chat channels with instant switching
- Discord-inspired UI using TailwindCSS
- Message persistence within the LiveView session
- User identification system
- Responsive design

## Prerequisites

- Elixir 1.14 or later
- Phoenix 1.7 or later
- PostgreSQL (optional, current version stores messages in memory)
- Node.js 14 or later (for asset compilation)

## Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd chat
```

2. Install dependencies:

```bash
mix deps.get
mix deps.compile
```

3. Install Node.js dependencies:

```bash
cd assets
npm install
cd ..
```

4. Start the Phoenix server:

```bash
mix phx.server
```

Now you can visit [`localhost:4000/chat`](http://localhost:4000/chat) from your browser.

## Project Structure

```
lib/
├── discord_clone/
│   └── application.ex
├── discord_clone_web/
│   ├── live/
│   │   └── server_live/    # Main LiveView modules
    |       └── index.ex
    |       └── show.ex
│   ├── router.ex
│   └── endpoint.ex
test/
├── discord_clone_web/
│   └── live/               # LiveView tests
└── support/
    └── conn_case.ex
```

## Key Components

The app handles:

- Real-time message broadcasting
- Channel management
- User session management
- User connection tracking
- UI rendering

## Testing

Run the test suite:

```bash
mix test
```

The test suite covers:

- LiveView mounting
- Message sending and receiving
- Channel switching
- Real-time updates
- User management

## Deployment

This application can be deployed to any platform that supports Phoenix applications. For Heroku deployment:

1. Add build packs:

```bash
heroku buildpacks:add hashnuke/elixir
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
```

2. Configure environment variables:

```bash
heroku config:set SECRET_KEY_BASE=$(mix phx.gen.secret)
heroku config:set PHX_HOST=your-app-name.herokuapp.com
```

## Future Improvements

1. **Persistence**

   - Add database storage for messages
   - Implement message history

2. **User Features**

   - User authentication
   - User profiles and avatars
   - Online status tracking

3. **Channel Features**

   - Private channels
   - Direct messaging
   - Channel permissions

4. **UI Enhancements**
   - Message formatting
   - File uploads
   - Emoji support
   - Typing indicators

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Acknowledgments

- Phoenix Framework team for LiveView
- Discord for UI inspiration
- TailwindCSS for styling utilities
