# WorldOS Phoenix Umbrella

An Elixir/Phoenix umbrella application for WorldOS, providing a modular architecture with multiple specialized apps working together.

## Project Structure

This umbrella project consists of the following applications:

- **`:core`** - Domain/data application with binary UUID primary keys
- **`:gateway_web`** - Phoenix web application providing JSON API endpoints
- **`:ai_bridge`** - Python integration bridge for AI capabilities

## Setup & Installation

### Prerequisites

- Elixir 1.14 or later
- Phoenix 1.7 or later
- PostgreSQL
- Python 3

### Development Setup

1. Clone the repository
   ```bash
   git clone https://github.com/cosmic-intelligence/worldos-phx-umbrella.git
   cd worldos-phx-umbrella
   ```

2. Install dependencies
   ```bash
   mix deps.get
   ```

3. Setup the database
   ```bash
   mix ecto.setup
   ```

4. Start the Phoenix server
   ```bash
   mix phx.server
   ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Development Workflow

This project follows a standard Git flow with three primary branches:
- `main` - Production-ready code
- `staging` - Pre-production testing
- `dev` - Active development

Always create feature branches from `dev` and submit pull requests back to the `dev` branch.

## Applications

### Core

The Core application handles domain logic and database interactions using:
- Ecto for database access
- Binary UUIDs for primary keys
- PostgreSQL as the database

### Gateway Web

The Gateway Web application provides the API interface:
- JSON-only API (no HTML/assets)
- API endpoints for client communication
- Integration with Core for data access

### AI Bridge

The AI Bridge application enables Python integration:
- Communication between Elixir and Python
- Machine-learning features powered by Python libraries

## Domain Development Pattern (Hand-crafted approach)

We purposefully avoid the big `phx.gen.*` generators and add each resource
by hand.  
This keeps noise to an absolute minimum and makes every byte of production
code obvious.

**Step-by-step recipe (repeat for every new table / API):**

1. **Migration**  
   ```bash
   mix ecto.gen.migration create_<table_name>
   ```  
   Open the file and write the full DDL yourself (extensions, enums,
   cascading FKs, partial indexes).

2. **Schema** (`apps/core/lib/core/<context>/<schema>.ex`)  
   Use binary UUID primary keys and `Ecto.Enum` for status/role columns.

3. **Context** (`apps/core/lib/core/<context>.ex`)  
   Add only the CRUD helpers you need.  Nothing more.

4. **Tests** (`apps/core/test/core/<context>_test.exs`)  
   Use `Core.DataCase` so every test runs inside an SQL sandbox.

5. **Gateway API**  
   • Add a controller under  
     `apps/gateway_web/lib/gateway_web/controllers/`  
   • Wire routes in `apps/gateway_web/lib/gateway_web/router.ex`

6. `mix ecto.migrate && mix test` – repeat until green.

---

### Implemented example – Users

Files introduced/edited:

## License

MIT