# Query Streaming Bug Hunt Script
This repository contains a script used for bug hunts to test the query streaming pipelines.

## Setup
Update the credentials in `credentials.rb`. Set `CLIENT_ID` and `CLIENT_SECRET` to your client id and secret for the user you want to test on master.

## Install Dependencies
```bash
> bundle install
```

## Run
```bash
> bin/export <poi or ssf or both> <query_id: id or quid> [<apply formatting: true or false>] [<dev mode: true or false>]
```
