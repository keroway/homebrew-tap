class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.27.0/tdsl-macos-aarch64.tar.gz"
      sha256 "5eac223b8866050a9fc40d9d94edd55514319c5abf1edce45f10f65e42d2802c"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.27.0/tdsl-macos-x86_64.tar.gz"
      sha256 "79eed859dabd3c06b8249f0ddec441c949e168482e57e763f975b70fc7ee81c8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.27.0/tdsl-linux-aarch64.tar.gz"
      sha256 "84a6d15962de93b676f90c39cce4dadfa886e9e746b3c1bc5dfdd767c8510e68"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.27.0/tdsl-linux-x86_64.tar.gz"
      sha256 "b4e823ef9805dcee58878ce9b2fc85abe727bb933972ff57e64e509a510282ad"
    end
  end

  def install
    bin.install "tdsl"
  end

  test do
    assert_match "tdsl", shell_output("#{bin}/tdsl --version")
    (testpath/"test.tdsl").write <<~EOS
      timeline "test" {
        unit year;
        range 1..100;
      }
      lane "main" as main { kind dynasty; order 1; }
      span main 10..50 "test span" {};
    EOS
    assert_match "lanes", shell_output("#{bin}/tdsl build #{testpath}/test.tdsl --pretty")
  end
end
