class Manticore < Formula
  desc "PHP-to-native AOT compiler: compiles PHP 8.5 to standalone binaries via LLVM"
  homepage "https://github.com/manticorephp/compiler"
  url "https://github.com/manticorephp/compiler/releases/download/v0.18.0/manticore-0.18.0-macos-arm64.tar.gz"
  sha256 "e28ddd135ce6ca5362a3b9513e97c5a208208c3db5e772cdf13536b10393961c"
  license "MIT"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  # Published builds: macOS arm64 only (minos 15.0); Linux uses install.sh, the
  # ghcr.io image or the release tarballs. openssl@4 + pcre2: linked by the
  # compiler and by every program it builds. icu4c (keg-only, via opt/icu4c):
  # ext/intl. pkgconf: discovers the openssl and ICU link flags.
  depends_on arch: :arm64
  depends_on "icu4c"
  depends_on macos: :sequoia
  depends_on "openssl@4"
  depends_on "pcre2"
  depends_on "pkgconf"
  # From macOS itself: clang/cc (Command Line Tools, LLVM >= 15), libz,
  # libiconv, and the demand-gated libcurl, libsqlite3, libxml2.

  def install
    libexec.install "bin", "lib"
    bin.install_symlink libexec/"bin/manticore"
  end

  def caveats
    other = Pathname(ENV.fetch("MANTICORE_HOME", "#{Dir.home}/.manticore"))/"bin/manticore"
    return unless other.exist?

    <<~EOS
      An install.sh copy of manticore also exists at #{other}.
      Whichever comes first in PATH wins: remove one (rm -rf #{other.dirname.dirname})
      or keep #{HOMEBREW_PREFIX}/bin ahead of it.
    EOS
  end

  test do
    (testpath/"t.php").write <<~PHP
      <?php
      echo preg_replace('/(\\d+)/', '<$1>', 'a1b22'), "\\n";
      echo hash_hmac('sha256', 'x', 'k'), "\\n";
      echo mb_strtoupper('ïñ'), "\\n";
      echo Normalizer::normalize("e\\u{301}") === "\\u{e9}" ? "icu\\n" : "no icu\\n";
    PHP
    system bin/"manticore", "compile", "t.php", "-o", "t"
    assert_equal <<~OUT, shell_output("./t")
      a<1>b<22>
      #{OpenSSL::HMAC.hexdigest("SHA256", "k", "x")}
      ÏÑ
      icu
    OUT
  end
end
