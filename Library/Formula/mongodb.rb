require 'formula'
require 'hardware'

class MongoClient <Formula
  homepage 'http://mongodb.com/'
  url 'http://downloads.mongodb.org/src/mongodb-src-r1.2.2.tar.gz'
  md5 '278f8d234c6d1e8bcca6301d60876787'

  depends_on 'scons'
  depends_on 'boost'
  depends_on 'pcre'

  def patches
    DATA
  end
end


class Mongodb <Formula
  homepage 'http://www.mongodb.org/'

  aka :mongo

  def options
    [
      ["--cxx", "build working C++ client library"],
    ]
  end

  if ARGV.include? '--cxx'
    # Deps needed for building libmongoclient.a
    MongoClient.deps.each do |dep|
      depends_on dep
    end
  end


  if Hardware.is_64_bit? and not ARGV.include? '--32bit'
    url 'http://downloads.mongodb.org/osx/mongodb-osx-x86_64-1.4.4.tgz'
    md5 '8791c484c1580d563f1a071e5eed9fa5'
    version '1.4.4-x86_64'
  else
    url 'http://downloads.mongodb.org/osx/mongodb-osx-i386-1.4.4.tgz'
    md5 '8e31cc8b8f4879812cad217ce5b49b20'
    version '1.4.4-i386'
  end

  def skip_clean? path
    true
  end

  def install
    # Dont install the libmongoclient and header files from this tarbal - it
    # wont link with the version of boost in homebrew
    File.unlink 'lib/libmongoclient.a'
    FileUtils.rm_rf 'include/mongo'

    # If they asked for the lib, install it.
    if ARGV.include? '--cxx'
      MongoClient.new.brew {
        system "scons",
                "--release",
                "--noshell",
                "--release",
                "--nojni",
                "mongoclient"

        #include.install(Dir['include/*'])
        lib.install('libmongoclient.a')

        [ "", "util/", "db/" , "client/" ].each {|id|
          (include+"mongo/#{id}").install(Dir["#{id}*.h"])
        }
      }
    end

    # Copy the prebuilt binaries to prefix
    system "cp -prv * #{prefix}"

    # Create the data and log directories under /var
    (var+'mongodb').mkpath
    (var+'log/mongodb').mkpath

    # Write the configuration files and launchd script
    (prefix+'mongod.conf').write mongodb_conf
    (prefix+'org.mongodb.mongod.plist').write startup_plist

  end

  def caveats; <<-EOS
If this is your first install, automatically load on login with:
    cp #{prefix}/org.mongodb.mongod.plist ~/Library/LaunchAgents
    launchctl load -w ~/Library/LaunchAgents/org.mongodb.mongod.plist

If this is an upgrade and you already have the org.mongodb.mongod.plist loaded:
    launchctl unload -w ~/Library/LaunchAgents/org.mongodb.mongod.plist
    cp #{prefix}/org.mongodb.mongod.plist ~/Library/LaunchAgents
    launchctl load -w ~/Library/LaunchAgents/org.mongodb.mongod.plist

Or start it manually:
    mongod run --config #{prefix}/mongod.conf

To get the C++ client library, (re)install with the `--cxx' option
EOS
  end

  def mongodb_conf
    return <<-EOS
# Store data in #{var}/mongodb instead of the default /data/db
dbpath = #{var}/mongodb

# Only accept local connections
bind_ip = 127.0.0.1
EOS
  end

  def startup_plist
    return <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>org.mongodb.mongod</string>
  <key>ProgramArguments</key>
  <array>
    <string>#{bin}/mongod</string>
    <string>run</string>
    <string>--config</string>
    <string>#{prefix}/mongod.conf</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>UserName</key>
  <string>#{`whoami`.chomp}</string>
  <key>WorkingDirectory</key>
  <string>#{HOMEBREW_PREFIX}</string>
  <key>StandardErrorPath</key>
  <string>#{var}/log/mongodb/output.log</string>
  <key>StandardOutPath</key>
  <string>#{var}/log/mongodb/output.log</string>
</dict>
</plist>
EOS
  end
end


__END__
diff --git a/SConstruct b/SConstruct
index 5d0b835..5029467 100644
--- a/SConstruct
+++ b/SConstruct
@@ -260,8 +260,8 @@ if ( usesm and usejvm ):
     print( "can't say usesm and usejvm at the same time" )
     Exit(1)
 
-if ( not ( usesm or usejvm or usev8 ) ):
-    usesm = True
+#if ( not ( usesm or usejvm or usev8 ) ):
+#    usesm = True
 
 if GetOption( "extrapath" ) is not None:
     for x in GetOption( "extrapath" ).split( "," ):

