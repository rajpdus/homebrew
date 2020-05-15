require "formula"

class PyluceneDr < Formula
  homepage "http://lucene.apache.org/pylucene/index.html"
  url "https://www.apache.org/dist/lucene/pylucene/pylucene-7.7.1-src.tar.gz"
  sha256 "67f84ad6faba900bb35a6a492453e96ea484249ea9e8576ee71facbd05bade84"

  option "with-shared", "build jcc as a shared library"

  depends_on "python"

  patch :DATA

  def install
    ENV.prepend_create_path "PYTHONPATH", lib/"python2.7/site-packages"
    jcc = "JCC=python -m jcc --arch #{MacOS.preferred_arch}"
    opt = "INSTALL_OPT=--prefix #{prefix}"
    if build.with? "shared"
      jcc << " --shared"
      opoo "shared option requires python to be built with the same compiler: #{ENV.compiler}"
    else
      opt << " --use-distutils"  # setuptools only required with shared
      ENV["NO_SHARED"] = "1"
    end

    cd "jcc" do
      system "python", "setup.py", "install", "--prefix=#{prefix}", "--single-version-externally-managed", "--record=install.txt"
    end
    ENV.deparallelize  # the jars must be built serially
    system "make", "all", "install", opt, jcc, "ANT=ant", "PYTHON=python", "NUM_FILES=8"
  end

  test do
    ENV.prepend_path "PYTHONPATH", HOMEBREW_PREFIX/"lib/python2.7/site-packages"
    system "python", "-c", "import lucene; assert lucene.initVM()"
  end
end


__END__
diff --git a/Makefile b/Makefile
index ba74495..42d15c4 100644
--- a/Makefile
+++ b/Makefile
@@ -155,7 +155,7 @@ JARS+=$(EXTENSIONS_JAR)         # needs highlighter contrib
 JARS+=$(QUERIES_JAR)            # regex and other contrib queries
 JARS+=$(QUERYPARSER_JAR)        # query parser
 JARS+=$(SANDBOX_JAR)            # needed by query parser
-#JARS+=$(SMARTCN_JAR)            # smart chinese analyzer
+JARS+=$(SMARTCN_JAR)            # smart chinese analyzer
 JARS+=$(STEMPEL_JAR)            # polish analyzer and stemmer
 #JARS+=$(SPATIAL_JAR)            # spatial lucene
 JARS+=$(GROUPING_JAR)           # grouping module
@@ -342,6 +342,7 @@ GENERATE=$(JCC) $(foreach jar,$(JARS),--jar $(jar)) \
                              java.io.FileInputStream \
                              java.io.DataInputStream \
            --exclude org.apache.lucene.sandbox.queries.regex.JakartaRegexpCapabilities \
+                  --exclude org.apache.lucene.analysis.cn.smart.AnalyzerProfile\
            --exclude org.apache.regexp.RegexpTunnel \
            --python lucene \
            --mapping org.apache.lucene.document.Document 'get:(Ljava/lang/String;)Ljava/lang/String;' \
