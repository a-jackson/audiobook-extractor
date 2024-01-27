{ bash
, coreutils
, aaxtomp3
, audible-cli
, lib
, resholve
, bc
, ffmpeg
, findutils
, gawk
, gnugrep
, gnused
, jq
, lame
, mediainfo
, mp4v2
, ncurses
}:

resholve.mkDerivation rec {
  pname = "audiobook-extractor";
  version = "1.0";

  src = ../.;

  postPatch = ''
    substituteInPlace aaxtomp3 \
      --replace 'AAXtoMP3' 'aaxtomp3'
  '';

  installPhase = ''
    install -Dm 755 audiobook-extractor $out/bin/audiobook-extractor
    install -Dm 755 aaxtomp3 $out/bin/aaxtomp3
  '';

  solutions.default = {
    scripts = [
      "bin/audiobook-extractor"
      "bin/aaxtomp3"
    ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      audible-cli
      coreutils
      bc
      ffmpeg
      findutils
      gawk
      gnugrep
      gnused
      jq
      lame
      mediainfo
      mp4v2
      ncurses
    ];
    keep."$call" = true;
    keep."${placeholder "out"}/bin/aaxtomp3" = true;
    fix = {
      "$AAXtoMP3" = [ "${placeholder "out"}/bin/aaxtomp3" ];
      "$AUDIBLE" = [ "audible" ];
      "$FIND" = [ "find" ];
      "$GREP" = [ "grep" ];
      "$SED" = [ "sed" ];
      "$FFPROBE" = [ "ffprobe" ];
      "$FFMPEG" = [ "ffmpeg" ];
    };
    execer = [
      "cannot:${audible-cli}/bin/audible"
    ];
  };

  meta = with lib; {
    description = "Download from Audible and convert to mp3";
    homepage = "https://github.com/a-jackson/audiobook-extractor";
    license = licenses.gpl3;
  };
}
