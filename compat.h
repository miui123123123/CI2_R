// =====================================================
// compat.h
// Compatibility layer for modern C++
// Provides std::set_unexpected for C++17+
// =====================================================

#ifndef OCI_COMPAT_H
#define OCI_COMPAT_H

#include <exception>
#include <cstdlib>

#if __cplusplus >= 201103L
// C++11+: set_unexpected was removed.
// We provide a no-op fallback to keep old code compiling.

namespace std {
    typedef void (*unexpected_handler_t)();

    inline unexpected_handler_t set_unexpected(unexpected_handler_t handler) {
        // In C++17+, std::unexpected is deprecated/removed.
        // We keep the old code working by providing a no-op.
        (void)handler;
        return nullptr;
    }
}

// Also provide std::unexpected as fallback
namespace std {
    inline void unexpected() {
        std::terminate();
    }
}

#endif

#endif // OCI_COMPAT_H
