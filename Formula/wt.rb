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

  def caveats
    <<~EOS
      Add wt to your shell by appending this line to ~/.zshrc:

        source "#{HOMEBREW_PREFIX}/share/wt/shell-integration.zsh"

      Then reload your shell:

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
