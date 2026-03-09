# README

Things you may want to cover:

- Ruby version
  2.6.3

- Dependencies

ffmpeg, imagemagick

- Database creation

```
rails db:create
rails db:migrate
rails db:seed
# or just run
rails db:refresh
```

- How to run the test suite

```
bundle exec rspec
```

- Services (job queues, cache servers, search engines, etc.)

```
sidekiq
```

- Deployment instructions

```
cap staging deploy
```

- Cloud Run (stg)

Staging domains:

- https://admin.stg.hatamotohq.com
- https://user.stg.hatamotohq.com
- https://agency.stg.hatamotohq.com

Recommended env vars for stg:

- MIX_ROOT_PATH=
- DOMAIN=https://admin.stg.hatamotohq.com

Deploy (buildpacks):

```
gcloud run deploy hotel-insight-crm-stg \
  --source . \
  --region asia-northeast1 \
  --project lucky-display-390005 \
  --set-env-vars MIX_ROOT_PATH=,DOMAIN=https://admin.stg.hatamotohq.com
```
