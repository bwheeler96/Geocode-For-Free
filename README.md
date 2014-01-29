Geocode-For-Free
================

Geocode within the U.S. and Canada completely free of charge.

### Setup

Note that you have the option to use the hosted version of this project, at [geocodeforfree.com](http://geocodeforfree.com), however if you want to host the project yourself here are the instructions.

### Get a copy

```
git clone git@github.com:bwheeler96/Geocode-For-Free.git
cd Geocode-For-Free
```

### Bundle

```
bundle install
```

### Setup the database

```
rake db:migrate
cat cities.sql | sqlite3 db/geocode.sqlite3
```

### Starting the server

```
ruby config.ru
```

Happy coding!
