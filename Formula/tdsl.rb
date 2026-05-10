class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  version "1.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-aarch64.tar.gz"
      sha256 "ce1594f3608262cc6a0bd7a131075c43bf2bc8e2c4b558cb071da2c79c6acc53"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-x86_64.tar.gz"
      sha256 "ae704b657afbb9e0a3116cf552aac8c9dead1c92c67d4c60f15034ffe06bf504"
    end
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-x86_64.tar.gz"
    sha256 "b91ecf1ac083c1663457d0781aca49e91f237f21f5a049a0864b3bc4bdaa2a14"
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
