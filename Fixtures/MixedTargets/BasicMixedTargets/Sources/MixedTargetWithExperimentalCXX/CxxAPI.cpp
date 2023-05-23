#include "CxxAPI.hpp"
#include "MixedTargetWithExperimentalCXX-Swift.h"

long CxxMultiplier::multiply(int x, int y) {
    return x * y;
}

int cxxAddOne(int x) {
    return x + 1;
}

int returnOne(int x) {
    return MixedTargetWithExperimentalCXX::swiftSayHello();
    return swiftSayHello();
}
