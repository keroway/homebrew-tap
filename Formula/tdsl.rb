class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  version "1.20.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-aarch64.tar.gz"
      sha256 "8724a18c8dab48d8b7b7d1fe9fc4042a8cb8c9e9a7b772b4465725cb822a5a44"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-x86_64.tar.gz"
      sha256 "ad90cfd16ccb7564ad01c6f5433d3a19f72dbbf3269822ff9e62f914df4672cf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-aarch64.tar.gz"
      sha256 "05eb1378fed25d8c8471eba674da0539603b8b913d2ff5cd53e3910f27e0089b"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-x86_64.tar.gz"
      sha256 "2749162488b85d258f8576f58561541e10cff27362cb47c3ade8d42d86261029"
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
