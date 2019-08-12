### API Caller - Trello TODO LIST
This is my simple project for logging anything I did yesterday and what is the tickets I need done today, even adding the tickets to my plan for the future

### Development
Goto `https://trello.com/app-key` to get `API KEY` and `API TOKEN`. After you have those keys, you have to rename `.env.example` to `.env` and insert those key there.

Open file `main.rb` and edit the arguments `start date` and `end date` at `def main`
```ruby
create_tasks(start_date: '30/07/2019', end_date: '30/08/2020', extra_option: {labels: %w(okiela medium)})
```

After that run

```bash
ruby main.rb
```

### TODO
Move the command and parameters to Rake task to run easier.


