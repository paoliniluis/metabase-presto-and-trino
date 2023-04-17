# What's this stack?

It's a Metabase server to test Presto, Trino and also Trino, but connected with the Presto driver so we can check the 3 scenarios altogether.
These 3 engines are connected to the same databases (mongo, postgres and mysql). Everything is automated so you just go to localhost:3000 and authenticate with a@b.com/metabot1 and you're good to go

## Diagram

```
       +------------+
       |   Metabase |-----------------------------------
       |   Server   |            |                     |
       +-----+------+            |                     |
             |                   |                     | 
             |                   |                     | 
             |                   |                     | 
       +-----+------+       +------------+       +------------+
       |    Trino   |       |    Presto  |       |  Trino w/  |
       |            |       |            |       |  Presto    |
       +------------+       +------------+       |   Driver   |
             |                     |             +------------+
             |                     |                   |
             |                     |                   |
       +-----+------+       +------------+       +-----+------+
       |   MongoDB  |       |   Postgres |       |    MySQL   |   
       |            |-------|            |-------|            |   
       +------------+       +------------+       +------------+   


```

## How to run

just do `docker compose up` after cloning the repository

## Things to take into account

- Metabase is containerized on the Dockerfile which is on metabase-starburst, so this is Mac M1 compatible.
- The version that runs is the latest version at the time the image was built
- The Starburst driver is the one that's also in that Dockerfile