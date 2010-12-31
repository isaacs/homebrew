require 'formula'

class Npm <Formula
  url 'http://registry.npmjs.org/npm/-/npm-0.2.13-3.tgz'
  sha1 'a3588e2815e04d12e5115a69fa6f1cf598bcb4aa'

  homepage 'http://npmjs.org/'
  head 'git://github.com/isaacs/npm.git'

  depends_on 'node'

  skip_clean 'share/npm'

  def config_binroot
    HOMEBREW_PREFIX+"share/npm/bin"
  end

  def config_manroot
    HOMEBREW_PREFIX+"share/npm/share/man"
  end

  def config_root
    HOMEBREW_PREFIX+"share/npm/lib"
  end

  def globalconfig; <<-EOS
root = #{config_root}
binroot = #{config_binroot}
manroot = #{config_manroot}
EOS
  end


  def install
    # Set a root & binroot that won't get wiped between updates
    config_root.mkpath
    config_manroot.mkpath
    config_binroot.mkpath

    # install the global config overrides
    (libexec+'npmrc').write globalconfig
    (prefix+"etc").install libexec+'npmrc'

    # bash-completion
    (prefix+'etc/bash_completion.d').install Dir['npm-completion.sh']

    # now self-install
    system "make dev"
  end

  def caveats; <<-EOS.undent

    npm will install libraries to:
      #{config_root}
    Add this to your NODE_PATH.

    npm will install binaries to:
      #{config_binroot}
    Add this to your PATH.

    npm will install man pages to:
      #{config_manroot}
    Add this to your MANPATH.

    You may override these configuration settings using:
      npm config

    To fully uninstall npm, do this:
      brew rm npm
      npm cache clean
      npm rm -rf npm

    To remove all the files installed by npm ever, do this:
      rm -rf #{HOMEBREW_PREFIX}/share/npm

    EOS
  end
end
