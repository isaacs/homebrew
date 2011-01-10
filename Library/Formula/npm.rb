require 'formula'

class Npm <Formula
  url 'http://registry.npmjs.org/npm/-/npm-0.2.14-4.tgz'
  sha1 '46e5a4e13efb55c57f730539e1feaa399e9c1ae5'

  homepage 'http://npmjs.org/'
  head 'git://github.com/isaacs/npm.git'

  depends_on 'node'

  skip_clean 'npm'

  def config_binroot
    HOMEBREW_PREFIX+"npm/bin"
  end

  def config_manroot
    HOMEBREW_PREFIX+"npm/share/man"
  end

  def config_root
    HOMEBREW_PREFIX+"npm/lib"
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
    You will now need to set up some environment variables
    to make npm work properly.

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

    To fully uninstall npm, leaving other node programs intact:
      brew rm npm
      npm cache clean
      npm rm -rf npm

    To fully remove all the files installed by npm ever:
      brew rm npm
      rm -rf #{HOMEBREW_PREFIX}/npm
    EOS
  end
end
