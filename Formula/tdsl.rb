class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.28.0/tdsl-macos-aarch64.tar.gz"
      sha256 "772b0707a86dede04d2dc1ba63f2adf945154c3b809114c1a726d571a359f7f8"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.28.0/tdsl-macos-x86_64.tar.gz"
      sha256 "c42d5b128bb524c215d82092df02e666a2953773b3af1dcf9a55966a91341cb5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.28.0/tdsl-linux-aarch64.tar.gz"
      sha256 "9f3fa8739789fd5551875b9e645f679a8abb4cc3f0236bc035787ba83d62cf91"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v1.28.0/tdsl-linux-x86_64.tar.gz"
      sha256 "6a9d472a8aebf57613f69f1d5ec94719976258ca24f7a43034e7cca1a1e3b59d"
    end
  end

  def install
    bin.install "tdsl"
    generate_completions_from_executable(bin/"tdsl", "completions")
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
