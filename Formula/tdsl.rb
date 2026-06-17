class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  version "1.19.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-aarch64.tar.gz"
      sha256 "20b6422748439b3c8a4f50802ea38d3656b972400fee12ca2e65d08d0d8b1592"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-x86_64.tar.gz"
      sha256 "cc2687b7c103dddc62cf3b459282ed5a1db8597214f68331d8cf87bcc53c74fa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-aarch64.tar.gz"
      sha256 "9c2e3bbaba45c6cb9c8dd6b23accb3871a737a9898656af8a227237c9a6b3d96"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-x86_64.tar.gz"
      sha256 "8c4d923ddd3c4f9e239a13a55cfaf362b151f30fffe2e9901df4ea2c1d740b0f"
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
