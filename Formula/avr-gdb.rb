class AvrGdb < Formula
  desc "GDB lets you to see what is going on inside a program while it executes"
  homepage "https://www.gnu.org/software/gdb/"

  url "https://ftp.gnu.org/gnu/gdb/gdb-10.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-10.1.tar.xz"
  sha256 "f82f1eceeec14a3afa2de8d9b0d3c91d5a3820e23e0a01bbb70ef9f0276b62c0"

  bottle do
    root_url "https://github.com/osx-cross/homebrew-avr/releases/download/avr-gdb-10.1"
    rebuild 2
    sha256 big_sur:  "faf18fb3757639648f02f2b84858245d248daa2045d5e429dd89eadac2590683"
    sha256 catalina: "a9cc065340d0ea8a6e77f91fb10114d3a6f874ba031203b7479d5dc0f17698d6"
  end

  depends_on "avr-binutils"

  depends_on "python@3.9"
  
  on_ventura do
    depends_on "texinfo" => :build
  end
  
  uses_from_macos "expat"
  uses_from_macos "ncurses"

  # Fix symbol format elf32-avr unknown in gdb
  patch do
    url "https://raw.githubusercontent.com/osx-cross/homebrew-avr/18d50ba2a168a3b90a25c96e4bc4c053df77d7dc/Patch/avr-binutils-elf-bfd-gdb-fix.patch"
    sha256 "7954f85d2e0f628c261bdd486df8e1a229bc5bacc6ea4a0da003913cb96543f6"
  end

  def install
    args = %W[
      --target=avr
      --prefix=#{prefix}

      --disable-debug
      --disable-dependency-tracking

      --disable-binutils

      --disable-nls
      --disable-libssp
      --disable-install-libbfd
      --disable-install-libiberty

      --with-python=#{Formula["python@3.9"].opt_bin}/python3.9
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  def caveats
    <<~EOS
      gdb requires special privileges to access Mach ports.
      You will need to codesign the binary. For instructions, see:

        https://sourceware.org/gdb/wiki/BuildingOnDarwin

      On 10.12 (Sierra) or later with SIP, you need to run this:

        echo "set startup-with-shell off" >> ~/.gdbinit
    EOS
  end
end
