# 🌱 Sprout Server

<div align="center">

![Sprout Server](public/icon.svg)

[![Rails](https://img.shields.io/badge/Rails-8.2.0-ff1744.svg?style=flat-square&logo=ruby-on-rails&logoColor=white&labelColor=1a1b26)](https://rubyonrails.org/)
[![Ruby](https://img.shields.io/badge/Ruby-3.3.0-bb0826.svg?style=flat-square&logo=ruby&logoColor=white&labelColor=1a1b26)](https://www.ruby-lang.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14.0+-0055FF.svg?style=flat-square&logo=postgresql&logoColor=white&labelColor=1a1b26)](https://www.postgresql.org/)
[![Hotwire](https://img.shields.io/badge/Hotwire-Turbo_&_Stimulus-7e57c2.svg?style=flat-square&logo=hotwire&logoColor=white&labelColor=1a1b26)](https://hotwired.dev/)
[![TailwindCSS](https://img.shields.io/badge/TailwindCSS-3.4-38bdf8.svg?style=flat-square&logo=tailwind-css&logoColor=white&labelColor=1a1b26)](https://tailwindcss.com/)

[![Build Status](https://img.shields.io/github/actions/workflow/status/mathisto/sprout-server/ci.yml?branch=trunk&style=flat-square&labelColor=1a1b26)](https://github.com/mathisto/sprout-server/actions)
[![License](https://img.shields.io/badge/license-MIT-7aa2f7.svg?style=flat-square&labelColor=1a1b26)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/mathisto/sprout-server/trunk.svg?style=flat-square&labelColor=1a1b26)](https://github.com/mathisto/sprout-server/commits/trunk)

*A modern, real-time plant monitoring system powered by ESP32 devices and Rails* 🪴

[Features](#-features) • [Getting Started](#-getting-started) • [Development](#-development) • [Deployment](#-deployment) • [Contributing](#-contributing)

</div>

## ✨ Features

- 🌿 Real-time plant moisture monitoring
- 📊 Beautiful, interactive charts and visualizations
- 🔔 Instant notifications when plants need attention
- 📱 Progressive Web App (PWA) support
- 🤖 ESP32 device integration
- 🔄 WebSocket-powered live updates
- 🎨 Modern, responsive UI with TailwindCSS
- 🧪 Comprehensive test suite

## 🚀 Getting Started

### Prerequisites

- Ruby 3.3.0
- PostgreSQL 14+
- Node.js 18+
- Yarn 1.x
- Redis (optional, for ActionCable in production)

### Quick Start

1. Clone the repository:
```bash
git clone https://github.com/mathisto/sprout-server.git
cd sprout-server
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Set up your environment:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Set up the database:
```bash
rails db:create db:migrate db:seed
```

5. Start the development server:
```bash
bin/dev
```

Visit http://localhost:3000 and start monitoring your plants! 🌱

## 💻 Development

### Running Tests

```bash
bundle exec rspec                 # Run all tests
bundle exec rspec spec/models     # Run specific test directory
bundle exec rspec spec/models/plant_spec.rb  # Run specific test file
```

### Code Quality

```bash
bundle exec rubocop              # Ruby style guide
bundle exec brakeman            # Security vulnerabilities
bundle exec bundle audit        # Gem vulnerabilities
```

### Architecture

```mermaid
%%{
  init: {
    'theme': 'base',
    'themeVariables': {
      'primaryColor': '#1a1b26',
      'primaryTextColor': '#a9b1d6',
      'primaryBorderColor': '#7aa2f7',
      'lineColor': '#7aa2f7',
      'secondaryColor': '#24283b',
      'tertiaryColor': '#414868'
    }
  }
}%%
graph TD
    A[ESP32 Device]:::iot -->|HTTP POST| B[Rails API]:::server
    B -->|WebSocket| C[Browser Client]:::client
    B -->|Store| D[(PostgreSQL)]:::db
    C -->|Real-time Updates| E[Dashboard]:::ui
    C -->|Notifications| F[Service Worker]:::worker

    classDef default fill:#1a1b26,stroke:#7aa2f7,color:#a9b1d6,stroke-width:2px
    classDef iot fill:#2ac3de,stroke:#7dcfff,color:#1a1b26,stroke-width:2px
    classDef server fill:#f7768e,stroke:#ff9e64,color:#1a1b26,stroke-width:2px
    classDef client fill:#9ece6a,stroke:#73daca,color:#1a1b26,stroke-width:2px
    classDef db fill:#bb9af7,stroke:#c0caf5,color:#1a1b26,stroke-width:2px
    classDef ui fill:#e0af68,stroke:#ff9e64,color:#1a1b26,stroke-width:2px
    classDef worker fill:#7aa2f7,stroke:#b4f9f8,color:#1a1b26,stroke-width:2px
```

## 📦 Deployment

This application uses [Kamal](https://kamal-deploy.org/) for deployment:

1. Set up your deployment configuration:
```bash
cp config/deploy.yml.example config/deploy.yml
# Edit deploy.yml with your server configuration
```

2. Deploy:
```bash
bin/kamal setup
bin/kamal deploy
```

## 🤝 Contributing

We love contributions! Please check out our [Contributing Guide](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Ruby on Rails](https://rubyonrails.org/) - The web framework that powers everything
- [Hotwire](https://hotwired.dev/) - For making real-time updates a breeze
- [TailwindCSS](https://tailwindcss.com/) - For the beautiful UI components
- [Chart.js](https://www.chartjs.org/) - For the gorgeous data visualizations
- All our [contributors](https://github.com/mathisto/sprout-server/graphs/contributors) 💚

---

<div align="center">

Made with 💚 by [Matt Kelly](https://github.com/mathisto)

<sub>Theme inspired by [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) 🌃</sub>

</div>
