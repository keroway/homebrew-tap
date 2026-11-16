class Tdsl < Formula
  desc "Timeline DSL compiler — text-based timelines with Wikidata import"
  homepage "https://github.com/keroway/timeline-dsl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v3.0.0/tdsl-macos-aarch64.tar.gz"
      sha256 "dd9b8654117f804b3c66d0453b7cfbfb7be62bdaefbd1bf29f79e4c4f564b727"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v3.0.0/tdsl-macos-x86_64.tar.gz"
      sha256 "90e0c37ef98df1985fcb40e17eb759eee8013b4eaedfc1d6689f10112f9c006b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/keroway/timeline-dsl/releases/download/v3.0.0/tdsl-linux-aarch64.tar.gz"
      sha256 "3f60e6f4a23aa2a9bc654df6635bf61e0da2a6060b014b6f75b6f772e15f3f04"
    else
      url "https://github.com/keroway/timeline-dsl/releases/download/v3.0.0/tdsl-linux-x86_64.tar.gz"
      sha256 "b4da156c1b955ff9dd6ff7422b15abfb14d7fb6406a56a52d4971fc626aaf1d0"
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
    # Formula の版と完全一致を要求する（版の直後に英数字・ドット・ハイフン・プラスが続く
    # 部分一致、すなわち数字の延長やプレリリース・不正な接尾辞は許容しない）。
    assert_match(/\btdsl #{Regexp.escape(version.to_s)}(?![\w.+-])/, shell_output("#{bin}/tdsl --version"))
    (testpath/"test.tdsl").write <<~EOS
      timeline "test" {
        unit year;
        range 1..100;
      }
      lane "main" as main { kind dynasty; order 1; }
      span main 10..50 "test span" {};
    EOS
    assert_match "lanes", shell_output("#{bin}/tdsl build #{testpath}/test.tdsl --pretty")

    system bin/"tdsl", "render", testpath/"test.tdsl", "-o", testpath/"out.html"
    assert_path_exists testpath/"out.html"
    assert_match "<svg", (testpath/"out.html").read

    assert_path_exists bash_completion/"tdsl"
    assert_path_exists zsh_completion/"_tdsl"
    assert_path_exists fish_completion/"tdsl.fish"
  end
end
