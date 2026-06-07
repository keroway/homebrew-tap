class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  version "1.15.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-aarch64.tar.gz"
      sha256 "1f7c8188b6177555244b063a77a3e25d4ca2311f2476b0a146f0783c810d438b"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-x86_64.tar.gz"
      sha256 "74d7ae3120ff1ea8af9c7ece389e838100c3ebab01f83fe0704175d9cc739357"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-aarch64.tar.gz"
      sha256 "efa542f2f1e807e86367d68b21990dda5804da973f0bfec33fbf4bc440fe6e7f"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-x86_64.tar.gz"
      sha256 "9a6dd87dfbb377b2dd82a98baee2f6c91aed8993275f245430d2ea7ecd76c313"
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
