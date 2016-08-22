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

- Ruby 2.1.3
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

##### `eventmachine` gem installation on OSX

As of OSX 10.11 (El Capitan) installing the `eventmachine` gem throws an error:

    In file included from binder.cpp:20:
    ./project.h:116:10: fatal error: 'openssl/ssl.h' file not found
    #include <openssl/ssl.h>
             ^
    1 error generated.
    make: *** [binder.o] Error 1

    make failed, exit code 2

This is caused by OSX deprecating the use of `openssl` in favour of
it's own TLS and crypto libraries (see
[Issue 102 for eventmachine](https://github.com/eventmachine/eventmachine/issues/602)). `openssl`
can be installed with brew:

    $ brew install openssl

And then you can install the gem:

    $ gem install eventmachine -v 1.0.7 -- --with-cppflags=-I/usr/local/opt/openssl/include

Forcing brew to symlink `openssl` like so  `brew link openssl --force` is not recommended anymore:

    Warning: Refusing to link: openssl
    Linking keg-only openssl means you may end up linking against the insecure,
    deprecated system OpenSSL while using the headers from Homebrew's openssl.
    Instead, pass the full include/library paths to your compiler e.g.:
      -I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib

Or see the issue mentioned above for alternative solutions.

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
