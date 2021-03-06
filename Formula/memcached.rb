class Memcached < Formula
  desc "High performance, distributed memory object caching system"
  homepage "https://memcached.org/"
  url "https://www.memcached.org/files/memcached-1.6.14.tar.gz"
  sha256 "54d63742c6886dcdc4e0c87f4439a2930a876cd9f2bfa01d699b0c6bad1707b3"
  license "BSD-3-Clause"
  head "https://github.com/memcached/memcached.git", branch: "master"

  livecheck do
    url :homepage
    regex(/href=.*?memcached[._-]v?(\d+(?:\.\d+){2,})\./i)
  end

  bottle do
    root_url "https://github.com/luongbang152/homebrew-mobile-e2e/releases/download/memcached-1.6.14"
    sha256 cellar: :any,                 big_sur:      "482a31e40a0a73fde8cd43283131108405148c65070162720999111f7606750a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3fecfbc9874604f4ff72dc78283fc5d852ef1e46ab540859675df863436c61b0"
  end

  depends_on "libevent"

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-coverage", "--enable-tls"
    system "make", "install"
  end

  service do
    run [opt_bin/"memcached", "-l", "localhost"]
    working_dir HOMEBREW_PREFIX
    keep_alive true
    run_type :immediate
  end

  test do
    pidfile = testpath/"memcached.pid"
    port = free_port
    args = %W[
      --listen=127.0.0.1
      --port=#{port}
      --daemon
      --pidfile=#{pidfile}
    ]
    args << "--user=#{ENV["USER"]}" if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]
    system bin/"memcached", *args
    sleep 1
    assert_predicate pidfile, :exist?, "Failed to start memcached daemon"
    pid = (testpath/"memcached.pid").read.chomp.to_i
    Process.kill "TERM", pid
  end
end
