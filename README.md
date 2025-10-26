# Frameable

<p align="center">
  <a href="https://www.ruby-lang.org/en/">
    <img src="https://img.shields.io/badge/Ruby-v3.3.2-brightgreen.svg" alt="ruby version">
  </a>
  <a href="http://rubyonrails.org/">
    <img src="https://img.shields.io/badge/Rails-v8.0.3-brightgreen.svg" alt="rails version">
  </a>
</p>

*Frameable*: A Geometric API
Frameable is a robust, API-only application built with Ruby on Rails designed for the registration and management of geometric objects: Frames and Circles.

The core function of the API is to enforce strict geometric validation rules—implemented using pure mathematical logic without a spatial extension like PostGIS. All object positioning and dimensioning are handled in centimeters, supporting decimal values for high precision.


## Getting Started

### Codebase

*Frameable* is built on Ruby on Rails and PostgreSQL.

### Prerequisites

- [Git](https://git-scm.com)
- [Docker](http://docker.com/)
- [docker-compose](https://docs.docker.com/compose/install/)
- [Dip](https://github.com/bibendi/dip)

### Installation

1. Make sure all the prerequisites are installed.
1. Clone the repository `git clone git@github.com:brunotoral/frameable.git`
1. Build the development container with `dip provision`. It will build a
docker image named `frameable-dev` with all the required tooling.
1. Start development server `dip rails server`

You're all set! Happy hacking! :tada:

### Running The App

You can run Rails server using the following command:

```sh
$ dip rails server
```

It will make the application available at `localhost:3000`.

### Running Rake Tasks

You can run any Rake tasks like `db:migrate` using the following command:

```sh
$ dip rails <rake-task>
```

### Running Tests: Rspec

You can run all tests using the following command:

```sh
$ dip rspec
```

### Running the Linter: Rubocop

You can run any Rubocop command like `rubocop -A` using the following command:

```sh
$ dip rubocop <rubocop-command>
```

### Running Guard

You can run Guard to watch files using the following command:

```sh
$ dip guard
```

## Documentation

You can see the endpoint documentation by running the command:

```sh
dip rails server
```

Then accessing the URL address:

```
http://localhost:3000/api-docs
```

- [Mathematical Explanation (English)](docs/mathematical-en.md)
- [Endpoints Documentation (English)](docs/endpoints-en.md)


