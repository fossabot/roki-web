# roki-web

![CI](https://github.com/falgon/roki-web/workflows/CI/badge.svg)
[![Known Vulnerabilities](https://snyk.io/test/github/falgon/roki-web/badge.svg?targetFile=package.json)](https://snyk.io/test/github/falgon/roki-web?targetFile=package.json)
[![CodeFactor](https://www.codefactor.io/repository/github/falgon/roki-web/badge?s=e4b1f45b3bb2dc89c42f654d991238ef7771bc9f)](https://www.codefactor.io/repository/github/falgon/roki-web)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/0f3e0d5c5bbe43a78eaeed7485b72c7f)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=falgon/roki-web&amp;utm_campaign=Badge_Grade)
[![Maintainability](https://api.codeclimate.com/v1/badges/e6574c3042df63bf6d41/maintainability)](https://codeclimate.com/github/falgon/roki-web/maintainability)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Ffalgon%2Froki-web.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Ffalgon%2Froki-web?ref=badge_shield)

The website and blog of roki.

## History

This is a project for a new website that integrates the following two sites.

* [Roki Profile](https://falgon.github.io/roki/)
    * Project: <https://github.com/falgon/roki>
* [roki.log](https://falgon.github.io/roki.log/)
    * Project: <https://bitbucket.org/r0ki/roki.log/> (secret)

These two will be discontinued in the future and replaced by this new website and
have the following characteristics.

* The website [Roki Profile](https://falgon.github.io/roki/) is deployed manually (maintained by snyk-bot)
* The blog [roki.log](https://falgon.github.io/roki.log/) is deployed bitbucket-pipelines 

I used bitbucket, a kind of Git service that I can use private repositories for free, 
because github couldn't use private repositories for free before.
But times have changed and now private repositories are now available for free and 
native CI (GitHub Actions) are also available.
In this project, I use hakyll, which is a static site generator, 
to manage the frontend library with node.js and have it managed with synk-bot. 
Deployment is done with github actions, drafts of blog posts are managed in another repository, 
and commits to a specific branch in that repository are triggered and pushed to this branch.
This makes it possible to make open source and keep drafts private, 
improving and integrating the previously separated management form.


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Ffalgon%2Froki-web.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Ffalgon%2Froki-web?ref=badge_large)