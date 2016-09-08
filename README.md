# wercker-bitbucket-download

A wercker bitbucket downloader written in `bash` and `curl`. Make sure you download file from Bitbucket

[![wercker status](https://app.wercker.com/status/94f767fe85199d1f7f2dd064f36802bb/s "wercker status")](https://app.wercker.com/project/bykey/94f767fe85199d1f7f2dd064f36802bb)

# Options

- `key` OAuth key
- `secret` OAuth secret
- `source_filename` filename path
- `dest_filename` filename for destination

OAuth needs a key and secret, together these are know as an OAuth consumer. You can create a consumer on any existing individual or team account. To create a consumer, do the following:


# Example

```yaml
build:
    steps:
        - wercker-bitbucket-download:
            key: g25sMaaBypPR4QccyH
            secret: dh87Krw9bwSFHMdr2mvw552LqNJdq
            source_filename: jetty.jar
            dest_filename: out_path/jetty_last.jar
```

# License

The MIT License (MIT)

# Changelog

## 0.0.1

- Initial release
