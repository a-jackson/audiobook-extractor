# Audiobook Extractor

This is a docker image that combines [Audible CLI](https://github.com/mkb79/audible-cli) and [AAXtoMP3](https://github.com/KrumpetPirate/AAXtoMP3) to download audibooks and extract them to MP3.

On first run you need to login your Audible account. This will be saved in the config directory for subsequent runs.

The script tracks the time you last ran and downloads all audiobooks since the last run.

```sh
docker run \
  --rm \
  -it \
  -v config:/config \
  -v $HOME/audiobooks:/dest \
  -v download:/tmp/audible \
  -v $HOME/complete:/complete \
  ghcr.io/a-jackson/audiobook-extractor:main \
  quickstart
```

Commands passed to the container are interpretted by Audible CLI, no command will perform the download.
You can add multiple profiles in this way and then use the `AUDIBLE_PROFILE` environment variable to control which to download.

Once a profile is created, run the container again without a command and it will download and extract your audiobooks.

```sh
docker run \
  --rm \
  -v config:/config \
  -v $HOME/audiobooks:/dest \
  -v download:/tmp/audible \
  -v $HOME/complete:/complete \
  ghcr.io/a-jackson/audiobook-extractor:main
```

On first run it will download your entire library. If you only want new titles create a file in the config volume called `lastrun` containing the date it should start from in yyyy-MM-dd format.
