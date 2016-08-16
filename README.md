# OpenRegister School Demo

## Deployment

### Environment variables

`HOST` is url of your site, e.g. https://your-app-name.herokuapp.com

`MAP_API_HOST` is [URL template for map tile server](http://leafletjs.com/reference.html#url-template), e.g. http://{s}.somedomain.com/blabla/{z}/{x}/{y}.png

`PHASE` the register phase, e.g. discovery

### Heroku deployment

To setup fresh heroku deployment:

```sh
heroku create --region eu --org <org>

heroku apps:rename <your-app-name>

heroku addons:create mongolab:sandbox

heroku addons:create memcachier:dev

heroku addons:destroy heroku-postgresql --confirm <your-app-name>

heroku config:set HOST=<site-url> MAP_API_HOST=<map-url-template> PHASE=<register-phase>

git push heroku master

heroku run rake db:seed

heroku open
```

