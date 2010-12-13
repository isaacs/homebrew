require 'formula'

class Npm <Formula
  url 'http://registry.npmjs.org/npm/-/npm-0.2.12-1.tgz'
  homepage 'http://npmjs.org/'
  sha1 'a6a1d796735ac94fac62152e1b610b0041317703'
  md5 '861342c6c93844d7d70f807623ae87e7'
  head 'git://github.com/isaacs/npm.git'

  depends_on 'node'

  def executable; <<-EOS
#!/bin/sh
export npm_config_globalconfig=#{npmrc}
exec "#{libexec}/cli.js" "$@"
EOS
  end

  def bin
    HOMEBREW_PREFIX+"bin"
  end

  def share_man
    HOMEBREW_PREFIX+"share/man"
  end

  def npmrc
    HOMEBREW_PREFIX+"etc/npmrc"
  end

  def node_lib
    HOMEBREW_PREFIX+"lib/node"
  end

  def globalconfig; <<-EOS
root = #{node_lib}
binroot = #{bin}
manroot = #{share_man}
EOS
  end


  def install
    # Set a root & binroot that won't get wiped between updates
    bin.mkpath

    prefix.install ["LICENSE", "README.md"]
    doc.install Dir["doc/*"]

    # install all the required libs in libexec so `npm help` will work
    libexec.install Dir["*"]

    # add "npm-" prefix to man pages link them into the libexec man pages
    man1.mkpath
    Dir.chdir libexec + "man1" do
      Dir["*"].each do |file|
        if file == "npm.1"
          ln_s "#{Dir.pwd}/#{file}", man1
        else
          ln_s "#{Dir.pwd}/#{file}", "#{man1}/npm-#{file}"
        end
      end
    end

    # install the wrapper executable
    (bin+"npm").write executable

    # install the global config overrides
    npmrc.write globalconfig
    (prefix+'etc').install npmrc

    # bash-completion
    (prefix+'etc/bash_completion.d').install libexec+'npm-completion.sh'
  end

  def caveats; <<-EOS.undent

    npm will install binaries to:
      #{bin}
    Add this to your PATH.

    npm will install libraries to:
      #{node_lib}
    Add this to your NODE_PATH.

    npm will install man pages to:
      #{share_man}
    Add this to your MANPATH.

    To install npm for programmatic use (require("npm")) do:
      npm install npm

    You may change these settings using the `npm config` command.

    EOS
  end
end
