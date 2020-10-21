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
> bin/export <old or new or both or test> <query_id: id or quid> <apply formatting: true or false> <apply vis: true or false> <dev mode: true or false>
```

## Example
```bash
# Run query with id 9vyXupTeatORbyUUI7ot2m with value formatting disabled, vis formatting enabled and dev mode off.
> bin/export 9vyXupTeatORbyUUI7ot2m false true true
```
