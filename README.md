# git-mirror-docker

This is a Docker image based on [`git-mirror`][git-mirror], for mirroring GitHub repos to GitLab/other Git remotes on a push webhook event from a GitHub repo.

## Image Details

* Port 80 is exposed to allow requests to `$WEBHOOK_PATH`
* Pass your SSH private key (`id_rsa`) to the `/root/.ssh/id_rsa` volume
* Pass these environment variables:
  * `$GIT_HOST` - the `host:port` of the Git host to mirror to
  * `$WEBHOOK_PATH` - the path to expose the webhook on, ex `/.gh-webhook`
  * `$WEBHOOK_SECRET` - a secret string entered in the GitHub webhook configuration, used to authenticate webhook requests

## Sample `docker run`

This sets up the webhook at `http://0.0.0.0:12345/.gh-webhook`.

```shell
docker run -p 12345:80 \
  --restart=always \
  -v /your/github/and/GIT_HOST/privkey:/root/.ssh/id_rsa \
  -e GIT_HOST=gitlab \
  -e WEBHOOK_PATH=/.gh-webhook \
  -e WEBHOOK_SECRET=your-github-webhook-pre-shared-secret \
  git-mirror:latest
```

## Sample `docker-compose.yml`

> ⚠ Protip: You can even run this in the same `docker-compose.yml` as your `gitlab-runner` and `gitlab-ce` images.

This sets up the webhook at `http://0.0.0.0:12345/.gh-webhook`.

```yml
  mirror:
    image: 'git-mirror:latest'
    restart: always
    ports:
    - '12345:80'
    environment:
    - GIT_HOST=gitlab
    - WEBHOOK_PATH=/.gh-webhook
    - WEBHOOK_SECRET=your-github-webhook-pre-shared-secret
    volumes:
    - '/your/github/and/GIT_HOST/privkey:/root/.ssh/id_rsa'
```

[git-mirror]: https://github.com/fasterthanlime/git-mirror/

## Notes

* The `owner/repo` folder pattern is kept when pushing to the new `$GIT_HOST`, so ensure that you have the correct repositories set up *before* you start sending webhook events.
* SSH `known_host` verification is DISABLED by default, since there can be no user interaction. Make sure you are only connecting via trusted networks.
  * To bypass this, pass an empty file in to the `/root/.ssh/config` volume, and pass in your desired `known_hosts` configuration as `/root/.ssh/known_hosts`
