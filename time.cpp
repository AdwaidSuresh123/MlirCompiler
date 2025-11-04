#include <chrono>
#include <iostream>
#include <cstdint>

extern "C" {
    int64_t get_time() {
        auto now = std::chrono::high_resolution_clock::now();
        auto duration = now.time_since_epoch();
        return std::chrono::duration_cast<std::chrono::microseconds>(duration).count();
    }
    
    void print_time(int64_t microseconds) {
        std::cout << "Computation time: " << microseconds / 1000.0 << " ms" << std::endl;
    }
}