class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  version "1.24.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-aarch64.tar.gz"
      sha256 "b6cc0c48ebe7c900aac678039e6447c2f1463d93931997aea7bd4ef49e579a02"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-macos-x86_64.tar.gz"
      sha256 "b4c149ba4d2643bacf9f8a65ce9e4117edb8c18e235fc256439ac8691ac783b4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-aarch64.tar.gz"
      sha256 "ad2dd5a2b4e21ee65c3ba7dcecd54278c099bf9c17a068ff44418ebdd91409a8"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v#{version}/tdsl-linux-x86_64.tar.gz"
      sha256 "49f6589a8ef493b417f9e7182fb78d077f5cbb98dfbf2642a73b768d33b07e23"
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
