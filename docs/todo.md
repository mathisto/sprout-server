# TODO List

## Core Features

- [x] Create Plant model
  - [x] Add validations
  - [x] Add moisture-related helper methods
- [x] Create MoistureReading model
  - [x] Validate readings (0-100 range)
  - [x] Associate with Plant
- [x] Create API endpoint for receiving moisture readings
  - [x] Accept POST requests with plant slug and moisture level
  - [x] Create plants automatically when new slugs are received
  - [x] Update plant info when additional attributes are provided
- [x] Add logging
  - [x] Log successful readings
  - [x] Log errors with context

## Web UI

- [x] Create basic layout with navigation
- [x] Create Dashboard controller and views
  - [x] Show all plants
  - [x] Display moisture status
- [x] Create Plants controller
  - [x] CRUD operations
  - [x] Form validation
- [x] Create plant detail view
  - [x] Show current moisture
  - [x] Show moisture history chart
  - [x] Show status indicators
- [x] Style with Tailwind CSS

## Enhancements

- [ ] Add notification system
  - [ ] Alert when moisture level is too low/high
  - [ ] Email notifications
- [ ] Add plant recommendations
  - [ ] Suggest watering schedule based on plant type
  - [ ] Recommend optimal moisture levels for different species
- [ ] Add multi-sensor support
  - [ ] Allow devices to report temperature, light, etc.
  - [ ] Show additional metrics in UI

## Documentation

- [x] Create API documentation
- [ ] Create user manual
- [ ] Create developer guide

## Testing

- [x] Write model tests for Plant
- [x] Write model tests for MoistureReading
- [x] Write controller tests for API
- [ ] Write system tests for web UI