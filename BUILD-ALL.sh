# الصق الكود
# Ctrl+O, Enter, Ctrl+X
chmod +x BUILD-ALL.sh
#!/data/data/com.termux/files/usr/bin/bash

# =====================================================
# BUILD-ALL.sh
# Automatic build script for Open Chicken Invaders
# Supports: Linux, Android (Termux), macOS, Windows (MinGW)
# =====================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================"
echo "  Chicken Invaders - Auto Build Script"
echo "========================================"
echo ""

# -------- 1. Detect OS --------
OS="unknown"
case "$(uname -s)" in
    Linux*)
        if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
            OS="termux"
        else
            OS="linux"
        fi
        ;;
    Darwin*)    OS="macos" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
    *)          OS="unknown" ;;
esac

echo "🖥️  Detected OS: $OS"
echo ""

# -------- 2. Install Dependencies --------
install_deps() {
    echo "📦 Installing dependencies..."
    case "$OS" in
        termux)
            pkg update -y
            pkg install -y clang make cmake ninja git python \
                sdl2 sdl2-mixer boost boost-headers boost-static \
                libtinyxml openal-soft libsndfile
            pip install scons 2>/dev/null || true
            ;;
        linux)
            if command -v apt-get >/dev/null; then
                sudo apt-get update
                sudo apt-get install -y build-essential cmake ninja-build \
                    libsdl2-dev libsdl2-mixer-dev libboost-all-dev \
                    libtinyxml-dev libopenal-dev libsndfile1-dev python3-pip
                sudo pip3 install scons
            elif command -v pacman >/dev/null; then
                sudo pacman -S --noconfirm base-devel cmake ninja \
                    sdl2 sdl2_mixer boost tinyxml openal libsndfile python-pip
                sudo pip install scons
            elif command -v dnf >/dev/null; then
                sudo dnf install -y gcc-c++ cmake ninja-build \
                    SDL2-devel SDL2_mixer-devel boost-devel \
                    tinyxml-devel openal-soft-devel libsndfile-devel python3-pip
                sudo pip3 install scons
            fi
            ;;
        macos)
            if ! command -v brew >/dev/null; then
                echo "❌ Homebrew not found. Install from https://brew.sh"
                exit 1
            fi
            brew install cmake ninja sdl2 sdl2_mixer boost tinyxml \
                openal-soft libsndfile scons
            ;;
        windows)
            echo "❌ On Windows, use MSYS2 or WSL."
            echo "   Or run this script inside WSL."
            exit 1
            ;;
    esac
    echo "✅ Dependencies installed"
}

# -------- 3. Build --------
build_project() {
    echo ""
    echo "🔨 Building..."
    
    mkdir -p build
    cd build
    
    if command -v cmake >/dev/null; then
        echo "Using CMake..."
        cmake .. -DCMAKE_BUILD_TYPE=Release
        cmake --build . -j$(nproc 2>/dev/null || echo 2)
    elif command -v scons >/dev/null; then
        echo "Using SCons..."
        cd ..
        scons --mode=release --c++11 -j1
    else
        echo "❌ Neither CMake nor SCons found!"
        exit 1
    fi
    
    cd "$SCRIPT_DIR"
    echo "✅ Build complete"
}

# -------- 4. Find Binary --------
find_binary() {
    echo ""
    echo "🔍 Looking for binary..."
    
    BINARY=""
    for name in ChickenInvaders chickeninvaders; do
        if [ -f "build/$name" ]; then
            BINARY="build/$name"
            break
        elif [ -f "$name" ]; then
            BINARY="$name"
            break
        fi
    done
    
    if [ -z "$BINARY" ]; then
        echo "❌ Binary not found!"
        exit 1
    fi
    
    chmod +x "$BINARY"
    echo "✅ Found: $BINARY"
}

# -------- 5. Test Run --------
test_run() {
    echo ""
    echo "🧪 Testing binary (5 seconds)..."
    echo ""
    
    # Try to run; timeout after 5s if available
    if command -v timeout >/dev/null; then
        timeout 5 "./$BINARY" || true
    else
        echo "⚠️  timeout not available, skipping test"
    fi
    
    echo ""
    echo "✅ Test complete"
}

# -------- 6. Package --------
package() {
    echo ""
    echo "📦 Packaging..."
    
    PKG_NAME="ChickenInvaders-$(uname -s)-$(uname -m)"
    mkdir -p "dist/$PKG_NAME"
    
    cp "$BINARY" "dist/$PKG_NAME/"
    cp -r res "dist/$PKG_NAME/" 2>/dev/null || true
    cp -r resources "dist/$PKG_NAME/" 2>/dev/null || true
    cp README.md "dist/$PKG_NAME/" 2>/dev/null || true
    
    cd dist
    tar czf "$PKG_NAME.tar.gz" "$PKG_NAME"
    cd ..
    
    echo "✅ Package: dist/$PKG_NAME.tar.gz"
}

# -------- Main --------
install_deps
build_project
find_binary
test_run
package

echo ""
echo "========================================"
echo "  🎉 ALL DONE!"
echo "========================================"
echo ""
echo "Binary:  $BINARY"
echo "Package: dist/ChickenInvaders-*.tar.gz"
echo ""
echo "To run:"
echo "  ./$BINARY"
echo ""
