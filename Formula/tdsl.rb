class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.0.0/tdsl-macos-aarch64.tar.gz"
      sha256 "79988d8ea97e2b37e963329bc75e29afb2715944ebb241b14e188586986763c6"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.0.0/tdsl-macos-x86_64.tar.gz"
      sha256 "922b7481cf002b02fdc99e72034f4353756ec1199d029f2be705a51956ec4bf2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.0.0/tdsl-linux-aarch64.tar.gz"
      sha256 "2f68de027286794f2e07c0315643bc3a1b2ce0050749e999f29b901bebd376fb"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v2.0.0/tdsl-linux-x86_64.tar.gz"
      sha256 "176722a7a6175923123dff89c160ce5fdfb2612888f3d1caf1039316b7a48ad8"
    end
  end

  def install
    bin.install "tdsl"
    generate_completions_from_executable(bin/"tdsl", "completions")
  end

  def caveats
    <<~EOS
      Bash, zsh, and fish completions for `tdsl` were generated, but Homebrew
      does not auto-link completions from external taps by default. Run this
      once to enable them:
        brew completions link
    EOS
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
