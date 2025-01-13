// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV3Quoter {
    // 正向报价方法，用于计算：当你想支付确定数量的代币A时，可以获得多少代币B。
    function quoteExactInput(bytes memory path, uint256 amountIn)
        external
        view
        returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );
    
    // 反向报价方法，用于计算：当你想获得确定数量的代币B时，需要支付多少代币A。
    function quoteExactOutput(bytes memory path, uint256 amountOut)
        external
        view
        returns (
            uint256 amountIn, // 需要支付的代币A数量
            uint160[] memory sqrtPriceX96AfterList, // 计算后的价格
            uint32[] memory initializedTicksCrossedList, // 跨越的价格档位数
            uint256 gasEstimate // 预估的gas消耗
        );
}