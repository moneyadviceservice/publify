# MAS Marketing Blog

[![Build Status](https://travis-ci.org/moneyadviceservice/publify.png)](https://travis-ci.org/moneyadviceservice/publify)
[![Code Climate](https://codeclimate.com/github/moneyadviceservice/publify.png)](https://codeclimate.com/github/moneyadviceservice/publify)
[![Dependency Status](https://gemnasium.com/moneyadviceservice/publify.png)](https://gemnasium.com/moneyadviceservice/publify)

## What is this?

The marketing blog application for the Money Advice Service.

## What's Publify?

We forked the blogging engine - Publify for purposes of the MAS Marketing Blog.

The feeling was that we would diverge far enough that tracking/merging upstream would be an issue.

Publify has been around since 2004 and is the oldest Ruby on Rails open source project alive.

## How do I run it?

### Installation

#### Prerequisites

- Ruby 2.4.2
- Node.js
- Bower
- MYSQL
- PhantomJS

Note: Make sure you've added all the required API keys for the app to work properly.

This repository comes equipped with a self-setup script:

```bash
$ ./bin/setup
$ rails s
```
##### `pg` gem issues on Mac OSx

When running the setup script you may run into an install issue with the *pg* (PostgreSQL) gem. If this occurs, you'll need to install it first via Homebrew `brew install postgresql` and then run the setup again.


#### Enviroment File Setup

You'll need to set the environment keys this repo requires in `.env` (which is auto generated when you run the setup script). If you're a MAS dev, you can grab these over at the [company wiki](https://moneyadviceserviceuk.atlassian.net/wiki/display/DEV/Marketing+Blog+Repo+Credentials).

#### Testing

```bash
$bundle exec rspec
```

Run with `COVERAGE=true` in your test environment to report on coverage.

```bash
$ ./node_modules/karma/bin/karma start ./spec/js/karma.conf.js --single-run
$ ./node_modules/jscs/bin/jscs app/assets/javascripts/components/
$ ./node_modules/jshint/bin/jshint app/assets/javascripts/components/ --config .jshintrc
```


#### Deploying to a test environment

The Blog (previously on Heroku) is now deployed via Go.

To deploy:
- Make a feature branch off of master and build the feature.
- Once you are in a position to deploy this feature, make a new branch from your local feature branch. The name of the new branch should be the name of the environment you want to deploy to: uat/qa/preview.
- git push -f origin <uat/qa/preview>
- In GO the blog_commit_<uat/qa/preview> pipeline will automatically start building. Once successfully complete all you need to do is start the deploy_to_<uat/qa/preview> pipeline. This grabs the responsive_commit, blog_commit and cms_commit and deploys all three applications.
- No version bumps are needed until you are deploying to staging
