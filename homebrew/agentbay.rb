class Agentbay < Formula
  desc "Secure infrastructure for running AI-generated code"
  homepage "https://github.com/litiantian257/agentbay-cli"
  url "https://github.com/litiantian257/agentbay-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "57a2ae69b42ef5caadc8f6b8abe754210cf86e5e8f3d625bd490e07d8891bfd7"
  license "MIT"
  head "https://github.com/litiantian257/agentbay-cli.git", branch: "main"

  depends_on "go" => :build

  def install
    # Set build variables matching the Makefile
    version = self.version
    # Use embedded git commit from build time (since tarball has no .git directory)
    git_commit = "93744d6"
    build_date = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

    # Set Go proxy for better network connectivity (especially in China)
    ENV["GOPROXY"] = "https://goproxy.cn,https://goproxy.io,https://proxy.golang.org,direct"
    ENV["GOSUMDB"] = "sum.golang.google.cn"
    ENV["GO111MODULE"] = "on"

    # Build flags matching your Makefile LDFLAGS (with optimization)
    ldflags = %W[
      -s
      -w
      -X github.com/agentbay/agentbay-cli/cmd.Version=#{version}
      -X github.com/agentbay/agentbay-cli/cmd.GitCommit=#{git_commit}
      -X github.com/agentbay/agentbay-cli/cmd.BuildDate=#{build_date}
    ]

    # Build from source using Go
    system "go", "build", *std_go_args(ldflags: ldflags), "."
  end

  test do
    # Test that binary is executable
    assert_predicate bin/"agentbay", :executable?

    # Test version command
    version_output = shell_output("#{bin}/agentbay version 2>&1")
    assert_match version.to_s, version_output

    # Test help command
    help_output = shell_output("#{bin}/agentbay --help")
    assert_match "agentbay", help_output
    assert_match "help", help_output
  end
end
