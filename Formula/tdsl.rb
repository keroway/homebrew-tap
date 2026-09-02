class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.1.0/tdsl-macos-aarch64.tar.gz"
      sha256 "5677a48eb3bb66506521735edbe3d411b44e0371ebe4b4294b8614d737ba4ce8"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.1.0/tdsl-macos-x86_64.tar.gz"
      sha256 "9f7c5b92104e1d2601a97b9c06dad4905c480488b96499efebc14ba9d54c363c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.1.0/tdsl-linux-aarch64.tar.gz"
      sha256 "ee7102edd4617dfcbe71d9ee03aeabf026c0836d7094fe7fd38ba2724722776a"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.1.0/tdsl-linux-x86_64.tar.gz"
      sha256 "e603e56c2387b4a22dd881047dc2a3f6a9cf0db3b5887de3f0845651dd7a6412"
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
