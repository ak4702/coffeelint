Release Steps
=============

1. Review changelog
-------------------

I always use the "Latest Changes" changelog link on
[coffeelint.github.io](https://coffeelint.github.io/#changelog) and change it
to point to `compare/vx.x.x...master`. Look through the pull requests to figure
out whether this is a minor or patch release.

2. Tag
------

CoffeeLint follows [semver](https://semver.org/). When a new rule is added even
if it's off by default, it's at least a minor release.

    npm version <major|minor|patch>

3. Release `coffeelint/coffeelint`
----------------------------------

    git push --follow-tags
    npm publish

I think it's important that people be able to install CoffeeLint directly from git.

4. Write changelog
------------------

The changelog is in `coffeelint/coffeelint.github.io/scripts/index-bottom.html` on
[`coffeelint/coffeelint.github.io`](https://github.com/coffeelint/coffeelint.github.io).
Update it based on the PRs found in step 1. I don't always mention every PR. Many internal
changes like updates to CI don't matter to users of CoffeeLint, so I leave them out.

5. Update `coffeelint/coffeelint.github.io`
-------------------------------------------

    npm run compile

This updates `js/coffeelint.js`, `js/coffeescript.js`, and `index.html`
This must be run **after** publishing the new version of coffeelint since it grabs it from npm.

6. Push website
---------------

    git push

GitHub Pages will automatically deploy when pushed to master
