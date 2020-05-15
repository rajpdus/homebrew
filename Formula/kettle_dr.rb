class KettleDr < Formula
  desc "Pentaho Data Integration software"
  homepage "http://community.pentaho.com/projects/data-integration/"
  url "https://downloads.sourceforge.net/project/pentaho/Data%20Integration/7.1/pdi-ce-7.1.0.0-12.zip"
  sha256 "e53a7e7327a50b19bb1d16a06d589a8ba3719e5a678abf5cea713503453d37f2"

  bottle :unneeded

  def install
    rm_rf Dir["*.{bat}"]
    libexec.install Dir["*"]

    (etc+"kettle").install libexec+"pwd/carte-config-master-8080.xml" => "carte-config.xml"
    (etc+"kettle/.kettle").install libexec+"pwd/kettle.pwd"
    (etc+"kettle/simple-jndi").mkpath

    (var+"log/kettle").mkpath

    # We don't assume that carte, kitchen or pan are in anyway unique command names so we'll prepend "pdi"
    %w[carte kitchen pan].each do |command|
      (bin+"pdi#{command}").write_env_script libexec+"#{command}.sh", :BASEDIR => libexec
    end
  end

  plist_options :manual => "pdicarte #{HOMEBREW_PREFIX}/etc/kettle/carte-config.xml"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/pdicarte</string>
          <string>#{etc}/kettle/carte-config.xml</string>
        </array>
        <key>EnvironmentVariables</key>
        <dict>
          <key>KETTLE_HOME</key>
          <string>#{etc}/kettle</string>
        </dict>
        <key>WorkingDirectory</key>
        <string>#{etc}/kettle</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/kettle/carte.log</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/kettle/carte.log</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/pdipan", "-file=#{libexec}/samples/transformations/Encrypt\ Password.ktr", "-level=RowLevel"
  end
end
