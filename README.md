# Internal Wallet System API

This application is a robust, API-only backend for an internal transactional wallet system. It's designed to handle multiple wallets for different types of entities, support multi-currency transactions, and ensure data integrity through professional development practices.

### Key Features
* **Polymorphic Wallets**: Any entity (`User`, `Team`, `Stock`) can own wallets.
* **Multi-Currency Support**: Each entity can hold multiple wallets, one for each currency.
* **ACID-compliant Transactions**: Uses database transactions and Single Table Inheritance for `Deposit`, `Withdrawal`, and `Transfer` operations.
* **Secure Authentication**: Session-based authentication for users.
* **Authorization**: Role-based access control for shared wallets (e.g., Team wallets).
* **Background Jobs**: Uses Sidekiq for recurring tasks like monthly balance snapshots.

---

### Ruby version

* Ruby 3.2.2
* Rails 7.x

---

### System dependencies

* **PostgreSQL**: Version 14 or higher.
* **Redis**: Version 6 or higher, required for Sidekiq.
* **Bundler**: To manage gems.

---

### Configuration

Configuration is managed through environment variables.

1.  Copy the example environment file:
    ```sh
    cp .env.example .env
    ```

2.  Edit the `.env` file to include your local database credentials and the required API key for the stock price service.
    ```env
    # .env
    DATABASE_USER=your_postgres_user
    DATABASE_PASSWORD=your_postgres_password
    RAPIDAPI_KEY=your_rapidapi_key_for_stock_prices
    ```

---

### Database creation

To create the development and test databases, run:
```sh
rails db:create
```

---

### Database initialization

1.  To apply the database schema, run the migrations:
    ```sh

    rails db:migrate
    ```

2.  To populate the database with initial seed data (e.g., a default user, team, etc.), run:
    ```sh
    rails db:seed
    ```

---

### How to run the test suite

The project uses RSpec for testing. To run the entire suite:
```sh
bundle exec rspec
```

---

### Services (job queues, cache servers, search engines, etc.)

This application uses **Sidekiq** for background job processing. You must have a Redis server running.

To start the Sidekiq worker process, run the following command in a separate terminal:
```sh
bundle exec sidekiq
```
To start the Rails server itself:
```sh
rails server
```

---

### API Endpoints

All endpoints are versioned under `/v1`. Here is a summary of the main endpoints:

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/auth` | Sign in a user. |
| `DELETE` | `/auth` | Sign out the current user. |
| `GET` | `/wallets/:id` | Get details for a specific wallet. |
| `GET` | `/users/:user_id/wallets`| Get all wallets for a user. |
| `POST` | `/wallet/deposits` | Create a deposit transaction. |
| `POST` | `/wallet/withdrawals`| Create a withdrawal transaction. |
| `POST` | `/wallet/transfers` | Create a transfer between two wallets. |
| `GET` | `/stock_prices` | Fetch stock prices from the external API. |