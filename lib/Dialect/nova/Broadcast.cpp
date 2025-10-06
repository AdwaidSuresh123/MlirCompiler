#include "Compiler/Dialect/nova/Broadcast.h"
#include "mlir/IR/BuiltinTypes.h"
#include <algorithm>

namespace mlir {
namespace nova {

std::optional<llvm::SmallVector<int64_t, 4>> 
computeBroadcastShape(llvm::ArrayRef<int64_t> lhsShape, 
                      llvm::ArrayRef<int64_t> rhsShape) {
  
  // Result will store the broadcasted shape
  llvm::SmallVector<int64_t, 4> resultShape;
  
  // We process dimensions from right to left (NumPy broadcasting rule)
  int lhsIdx = lhsShape.size() - 1;
  int rhsIdx = rhsShape.size() - 1;
  
  while (lhsIdx >= 0 || rhsIdx >= 0) {
    int64_t lhsDim = (lhsIdx >= 0) ? lhsShape[lhsIdx] : 1;
    int64_t rhsDim = (rhsIdx >= 0) ? rhsShape[rhsIdx] : 1;
    
    bool lhsDynamic = ShapedType::isDynamic(lhsDim);
    bool rhsDynamic = ShapedType::isDynamic(rhsDim);
    
    if (lhsDynamic || rhsDynamic) {
      resultShape.push_back(ShapedType::kDynamic);
    } 
    else if (lhsDim == rhsDim) {
      resultShape.push_back(lhsDim);
    } 
    else if (lhsDim == 1) {
      resultShape.push_back(rhsDim);
    } 
    else if (rhsDim == 1) {
      resultShape.push_back(lhsDim);
    } 
    else {

      return std::nullopt;
    }
    
    lhsIdx--;
    rhsIdx--;
  }
  
  // We built the shape backwards (right to left), so reverse it
  std::reverse(resultShape.begin(), resultShape.end());
  
  return resultShape;
}

bool isBroadcastCompatible(llvm::ArrayRef<int64_t> lhsShape,
                           llvm::ArrayRef<int64_t> rhsShape) {
  // Simply check if computeBroadcastShape succeeds
  return computeBroadcastShape(lhsShape, rhsShape).has_value();
}

llvm::SmallVector<int64_t> computeBroadcastDimensions(
    int64_t operandRank, int64_t resultRank) {
  llvm::SmallVector<int64_t> broadcastDims;
  
  // Compute the rank difference
  int64_t rankDiff = resultRank - operandRank;
  
  // Map operand dimensions to result dimensions (trailing alignment)
  for (int64_t i = 0; i < operandRank; ++i) {
    broadcastDims.push_back(rankDiff + i);
  }
  
  return broadcastDims;
}

}
}