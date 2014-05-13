## hubot-zesty [![NPM version](https://badge.fury.io/js/hubot-zesty.png)](http://badge.fury.io/js/hubot-zesty)

A [Hubot](https://github.com/github/hubot) plugin to tell you what Zesty is catering to your office today.

### Usage

    hubot zesty - Pulls your catering menu for today
    hubot zesty tomorrow - Tomorrow's catering menu

#### Configuration

You'll need to add a `HUBOT_ZESTY_ACCOUNT_NAME` variable into your environment with the value being that that exists in your Zesty menu URL: `www.zesty.com/account-name`

#### Heroku

    % heroku config:add HUBOT_ZESTY_ACCOUNT_NAME="your-zesty-account-name"

#### Non-Heroku environment variables

    % export HUBOT_ZESTY_ACCOUNT_NAME="your-zesty-account-name"

### Installation
1. Edit `package.json` and add `hubot-zesty` as a dependency.
2. Add `"hubot-zesty"` to your `external-scripts.json` file.
3. `npm install`
4. Reboot Hubot.
5. Get hungry.
