class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  url "https://github.com/keroway/timeline-dsl/releases/download/v1.4.1/tdsl-linux-x86_64.tar.gz"
  version "1.7.0"
  sha256 "e7a2d16d0d8db33d041d6b84eaebfbb29de7cf646b806931f2046327ca79ac8e"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-aarch64.tar.gz"
      sha256 "77fdda04b12322a6dab9b35e8b245fe95e46ab7a3a8a9e2663e70e00d60abe7f"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-x86_64.tar.gz"
      sha256 "80bf12e67ea3b098cb41a6680d743d32bb8e693cb33e92a63e9307d1f374719c"
    end
  end

  on_linux do
    on_arm do
      disable! date: "2024-01-01", because: "no ARM64 Linux binary is available"
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
