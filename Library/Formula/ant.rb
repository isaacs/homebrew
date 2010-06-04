require 'formula'

class Ant <Formula
  url 'http://apache.ziply.com/ant/source/apache-ant-1.8.1-src.tar.gz'
  homepage 'http://ant.apache.org'
  md5 '9e5960bd586d9425c46199cdd20a6fbc'

  def install
    Dir.chdir "lib/optional" do
      system "curl -L -O http://github.com/downloads/KentBeck/junit/junit-4.8.2.jar"
    end
    system "sh build.sh -Dant.install=#{prefix} install-lite"
  end
end
