# wercker-bitbucket-download

A wercker bitbucket downloader written in `bash` and `curl`. Make sure you download file from Bitbucket

[![wercker status](https://app.wercker.com/status/57746e2f7b50972661ae4b4cb44c11b1/m/ "wercker status")](https://app.wercker.com/project/byKey/57746e2f7b50972661ae4b4cb44c11b1)

# Options

- `key` OAuth key
- `secret` OAuth secret
- `source_filename` filename path
- `dest_dir`  destination directory

OAuth needs a key and secret, together these are know as an OAuth consumer. You can create a consumer on any existing individual or team account. To create a consumer, do the following:


# Example

```yaml
build:
    steps:
        - phantomx/bitbucket-download@0.0.1:
            key: g25sMaaBypPR4QccyH
            secret: dh87Krw9bwSFHMdr2mvw552LqNJdq
            source_file: 1.txt
            dest_dir: ./
```

# License

The MIT License (MIT)

# Changelog

## 0.0.1

- Initial release
