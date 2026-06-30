class Wt < Formula
  desc "Git worktree manager with shared AI context — wt setup, wt <branch>, wt --ai-status"
  homepage "https://github.com/rejsiperpalaj/homebrew-wt"
  head "https://github.com/rejsiperpalaj/homebrew-wt.git", branch: "main"

  def install
    # Main script — callable as wt-core from the shell integration function
    bin.install "libexec/wt-core" => "wt-core"
    chmod 0755, bin/"wt-core"

    # Shell integration (defines the wt() function)
    (share/"wt").install "share/wt/shell-integration.zsh"

    # Default context templates (seeded on wt setup)
    cp_r "share/wt/templates", share/"wt"
  end

  def post_install
    zshrc = File.expand_path("~/.zshrc")
    marker = "share/wt/shell-integration.zsh"
    line   = "source \"#{HOMEBREW_PREFIX}/share/wt/shell-integration.zsh\""

    unless File.exist?(zshrc) && File.read(zshrc).include?(marker)
      File.open(zshrc, "a") do |f|
        f.puts ""
        f.puts "# wt — git worktree + AI context manager (added by brew install wt)"
        f.puts line
      end
      puts "  → Added shell integration to ~/.zshrc"
      puts "    Run: source ~/.zshrc"
    else
      puts "  → Shell integration already present in ~/.zshrc — skipping"
    end
  end

  def caveats
    <<~EOS
      Shell integration was added to ~/.zshrc automatically.
      Reload your shell to activate wt:

        source ~/.zshrc

      ── Get started ──────────────────────────────────────
        cd ~/your/workspace
        wt setup git@github.com:your-org/your-repo.git
      ─────────────────────────────────────────────────────

      Each project gets its own isolated workspace. Repeat
      wt setup for every repo you want to manage this way.
    EOS
  end
end
