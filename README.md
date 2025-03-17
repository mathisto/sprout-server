# Sprout Server

A Rails application for managing ESP32-based plant monitoring and automation.

## Prerequisites

* Ruby 3.x
* PostgreSQL 14+
* Node.js 18+
* Docker (for deployment)

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/sprout-server.git
cd sprout-server
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Set up the database:
```bash
rails db:create db:migrate
```

5. Start the development server:
```bash
bin/dev
```

## Environment Variables

The following environment variables are required:

- `RAILS_MASTER_KEY`: Master key for Rails credentials
- `SPROUT_SERVER_DATABASE_PASSWORD`: Database password
- `REGISTRY_USERNAME`: Docker registry username
- `KAMAL_REGISTRY_PASSWORD`: Docker registry password

See `.env.example` for all available configuration options.

## Deployment

This application uses [Kamal](https://kamal-deploy.org/) for deployment.

1. Set up your deployment environment:
```bash
cp config/deploy.yml.example config/deploy.yml
# Edit deploy.yml with your server configuration
```

2. Deploy the application:
```bash
bin/kamal setup
bin/kamal deploy
```

## Testing

Run the test suite:
```bash
bundle exec rspec
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
