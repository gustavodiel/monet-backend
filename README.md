# MONET

Monet is a Proof of Concept of an API to handle financial management.
Being a PoC:
1. It lacks Authentication and Authorization (no users, no roles, no permissions)
2. It has no Rails basic configuration (no CORS, no SSL, no CSRF, etc)
3. It has no tests :eyes:
4. The commits are a total mess :sweat_smile:
5. It has not yer been tested on real life.

## Cool things about it

The idea of this PoC is to figure out a way of a possible production-ready financial management system that:
1. Can store all your transactions (income and expenses)
   1. Works almost like an event-sourcing system, where you can see the history of your transactions.
2. Does not take a kajillion years to load the data
   1. It does however takes some space due to cache, but it's minimal

## How it works
While not production-ready as the goal, it does some cool stuff with how it stores the transactions:
- Every Year has as many Months 
- Every Month has many entries and periodic entries 
  - Entries are the transactions that happen only once
  - Periodic entries are the transactions that happen every month or year (like rent, internet, netflix, etc)
- Periodic entries have many entries, one for each month or year that it happens.
  - Periodic entries also have the starting month and ending month
- [Month](./app/models/month.rb) is the most important entity in this architecture, as it has a cache in the `total` column which is the sum of all entries for that month and the months before it
  - Whenever something changes, the cache is updated for the month that the change happened and all the months after it
  - This way, when you want to see the total for a month, you don't have to calculate it, it's already there
  - Also, it applies interest rates calculation so that we can see how much money we will have each month

## Requirements
- Ruby 3.1.2
- Docker
- Docker Compose

### How to Run

```bash
docker-compose up -b
```
