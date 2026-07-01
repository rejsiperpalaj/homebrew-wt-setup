class WtSetup < Formula
  desc "Git worktree manager with shared AI context — wt setup, wt <branch>, wt --ai-status"
  homepage "https://github.com/rejsiperpalaj/homebrew-wt-setup"
  url "https://github.com/rejsiperpalaj/homebrew-wt-setup/archive/refs/tags/v1.0.17.tar.gz"
  sha256 "5bb8e501caaf40afec7e0056f177a6151c7e034bab4b17f506b84dd7851c0d48"
  version "1.0.17"
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
