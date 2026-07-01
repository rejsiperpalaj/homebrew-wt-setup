class WtSetup < Formula
  desc "Git worktree manager with shared AI context — wt setup, wt <branch>, wt --ai-status"
  homepage "https://github.com/rejsiperpalaj/homebrew-wt-setup"
  url "https://github.com/rejsiperpalaj/homebrew-wt-setup/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "d80fbbf73b85e97f6e1f09391b0c4d68ad8adfa29cdc0d02c920d0de61a8fbf7"
  version "1.0.2"
  head "https://github.com/rejsiperpalaj/homebrew-wt-setup.git", branch: "main"

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
      Add shell integration to your ~/.zshrc:

        echo 'source "#{opt_share}/wt/shell-integration.zsh"' >> ~/.zshrc

      Then activate it:

        source ~/.zshrc

      ── Get started ──────────────────────────────────────
        cd ~/your/workspace
        wt setup git@github.com:your-org/your-repo.git
      ─────────────────────────────────────────────────────

      Each project gets its own isolated workspace. Repeat
      wt setup for every repo you want to manage this way.

      ── To uninstall completely ───────────────────────────
        brew uninstall wt-setup
        sed -i '' '/wt\/shell-integration\.zsh/d' ~/.zshrc
      ─────────────────────────────────────────────────────
    EOS
  end
end
