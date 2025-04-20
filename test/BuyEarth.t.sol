// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BuyEarth} from "../src/BuyEarth.sol";
import {BuyEarthScript} from "../script/BuyEarth.s.sol";

contract BuyEarthTest is Test {
    BuyEarth public buyEarth;

    Account public owner = makeAccount("owner");
    address public user = makeAddr("user"); // 测试用户地址
    address public user2 = makeAddr("user2"); // 第二个测试用户地址
    address public receipt = makeAddr("receipt"); // 收款地址

    uint256 private PRICE = 0.001 ether;

    event BuySquare(uint8 idx, uint256 color);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event ColorChanged(uint8 indexed idx, uint256 color);
    event Deposited(address indexed sender, uint256 amount);

    function setUp() public {
        // 初始化合约
        vm.startPrank(owner.addr);
        buyEarth = new BuyEarth();
        vm.stopPrank();
    }

    // 测试初始状态
    function testInitialState() public view {
        assertEq(buyEarth.getOwner(), owner.addr);
        uint256[] memory squares = buyEarth.getSquares();
        assertEq(squares.length, 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(squares[i], 0);
        }
    }

    // 测试购买格子
    function testBuySquare() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000; // 红色
        uint256 price = PRICE;

        // 模拟用户操作
        vm.startPrank(user);
        deal(user, price * 2); // 分配双倍资金用于测试找零
        buyEarth.buySquare{value: price * 2}(testIdx, testColor);
        vm.stopPrank();

        // 验证格子颜色被修改
        assertEq(buyEarth.getColor(testIdx), testColor);
        assertEq(user.balance, price); // 应退回price的找零
    }

    // 测试购买格子边界条件
    function testBuySquareEdgeCases() public {
        uint256 price = PRICE;
        deal(user, price);

        // 测试无效的格子索引
        vm.startPrank(user);
        vm.expectRevert("Invalid square number");
        buyEarth.buySquare{value: price}(100, 0xFF0000);
        vm.stopPrank();

        // 测试无效的颜色值
        vm.startPrank(user);
        vm.expectRevert("Invalid color");
        buyEarth.buySquare{value: price}(1, 0x1000000);
        vm.stopPrank();

        // 测试金额不足
        vm.startPrank(user);
        vm.expectRevert("Incorrect price");
        buyEarth.buySquare{value: price - 1}(1, 0xFF0000);
        vm.stopPrank();
    }

    // 测试多个用户购买不同格子
    function testMultipleUsersBuySquares() public {
        uint256 price = PRICE;
        deal(user, price);
        deal(user2, price);

        vm.startPrank(user);
        buyEarth.buySquare{value: price}(1, 0xFF0000);
        vm.stopPrank();

        vm.startPrank(user2);
        buyEarth.buySquare{value: price}(2, 0x00FF00);
        vm.stopPrank();

        assertEq(buyEarth.getColor(1), 0xFF0000);
        assertEq(buyEarth.getColor(2), 0x00FF00);
    }

    // 测试所有者功能
    function testOwnerFunctions() public {
        // 测试设置颜色
        vm.startPrank(owner.addr);
        buyEarth.setColor(1, 0x0000FF);
        assertEq(buyEarth.getColor(1), 0x0000FF);
        vm.stopPrank();

        // 测试非所有者不能设置颜色
        vm.startPrank(user);
        vm.expectRevert("Only owner can call this function");
        buyEarth.setColor(1, 0x0000FF);
        vm.stopPrank();

        // 测试转移所有权
        vm.startPrank(owner.addr);
        buyEarth.setOwner(user);
        assertEq(buyEarth.getOwner(), user);
        vm.stopPrank();
    }

    // 测试事件
    function testEvents() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000;
        uint256 price = PRICE;
        deal(user, price);

        // 测试购买格子事件
        vm.startPrank(user);
        vm.expectEmit(true, true, true, true);
        emit BuySquare(testIdx, testColor);
        buyEarth.buySquare{value: price}(testIdx, testColor);
        vm.stopPrank();

        // 测试所有权转移事件
        vm.startPrank(owner.addr);
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(owner.addr, user);
        buyEarth.setOwner(user);
        vm.stopPrank();

        // 测试颜色变更事件
        vm.startPrank(user);
        vm.expectEmit(true, true, true, true);
        emit ColorChanged(testIdx, 0x00FF00);
        buyEarth.setColor(testIdx, 0x00FF00);
        vm.stopPrank();
    }

    // 测试直接转账
    function testDirectTransfer() public {
        deal(user, 1 ether);
        vm.startPrank(user);
        (bool success,) = address(buyEarth).call{value: 0.1 ether}("");
        assertTrue(success); // 验证转账成功
        assertEq(user.balance, 0.9 ether);
        assertEq(address(buyEarth).balance, 0.1 ether);
        vm.stopPrank();
    }

    // 测试提现边界条件
    function testWithdrawToEdgeCases() public {
        // 测试零地址提现
        vm.startPrank(owner.addr);
        vm.expectRevert("Invalid recipient address");
        buyEarth.withdrawTo(address(0));
        vm.stopPrank();

        // 测试无余额提现
        vm.startPrank(owner.addr);
        vm.expectRevert("No funds to withdraw");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
    }

    // 测试提现
    function testWithdraw() public {
        deal(address(buyEarth), 1 ether);
        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 1 ether);
        buyEarth.deposit{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);

        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 2 ether);
        vm.stopPrank();
    }

    function testDeposit() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 明确指定调用合约的deposit()
        (bool success,) = address(buyEarth).call{value: 0.1 ether}(abi.encodeWithSignature("deposit()"));
        require(success, "Deposit failed");

        vm.stopPrank();

        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);
    }

    function testWithdrawFromDeposit() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 明确指定调用合约的deposit()
        (bool success,) = address(buyEarth).call{value: 0.1 ether}(abi.encodeWithSignature("deposit()"));
        require(success, "Deposit failed");

        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);
        assertEq(user.balance, 0.9 ether);
        assertEq(address(buyEarth).balance, 0.1 ether);
        vm.stopPrank();

        vm.startPrank(owner.addr);

        buyEarth.withdrawTo(receipt);
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.1 ether);
        vm.stopPrank();

        assertEq(buyEarth.getUserDeposits(user), 0);
    }

    // 新增测试用例 1：测试购买地块时支付刚好等于 PRICE（无退款）
    function testBuySquareExactPrice() public {
        uint8 testIdx = 3;
        uint256 testColor = 0x00FF00; // 绿色

        vm.startPrank(user);
        deal(user, PRICE);
        buyEarth.buySquare{value: PRICE}(testIdx, testColor);
        vm.stopPrank();

        assertEq(buyEarth.getColor(testIdx), testColor);
        assertEq(user.balance, 0); // 无退款，余额应为 0
        assertEq(address(buyEarth).balance, 0); // 资金转给 owner
        assertEq(owner.addr.balance, PRICE); // owner 收到 PRICE
    }

    // 新增测试用例 2：测试同一用户多次存款
    function testMultipleDeposits() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 第一次存款
        buyEarth.deposit{value: 0.1 ether}();
        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);

        // 第二次存款
        buyEarth.deposit{value: 0.2 ether}();
        assertEq(buyEarth.getUserDeposits(user), 0.3 ether); // 累计存款

        vm.stopPrank();

        // 验证 depositorList 只记录一次用户地址
        // 由于 _getAllDepositors 是 private，间接验证 depositorList 行为
        assertEq(address(buyEarth).balance, 0.3 ether);
    }

    // 新增测试用例 3：测试多用户存款后 withdrawTo 清空 userDeposits
    function testWithdrawWithMultipleDepositors() public {
        deal(user, 1 ether);
        deal(user2, 1 ether);

        // 用户 1 存款
        vm.startPrank(user);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        // 用户 2 存款
        vm.startPrank(user2);
        buyEarth.deposit{value: 0.2 ether}();
        vm.stopPrank();

        // 验证初始存款
        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);
        assertEq(buyEarth.getUserDeposits(user2), 0.2 ether);
        assertEq(address(buyEarth).balance, 0.3 ether);

        // 拥有者提现
        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
        // 验证存款被清空
        assertEq(buyEarth.getUserDeposits(user), 0);
        assertEq(buyEarth.getUserDeposits(user2), 0);
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.3 ether);
    }

    // 测试 setColor 的无效索引
    function testSetColorInvalidIndex() public {
        vm.startPrank(owner.addr);
        vm.expectRevert("Invalid square number");
        buyEarth.setColor(100, 0xFF0000);
        vm.stopPrank();
    }

    // 测试 receive 函数的零金额转账
    function testReceiveZeroAmount() public {
        vm.startPrank(user);
        vm.expectRevert("Must send some ETH");
        (bool success,) = address(buyEarth).call{value: 0}("");
        assertTrue(success);
        vm.stopPrank();

        assertEq(buyEarth.getUserDeposits(user), 0);
        assertEq(address(buyEarth).balance, 0);
    }
    // 测试 owner 支付失败场景（模拟 owner 地址无法接收 ETH）

    function testBuySquareOwnerPaymentFailure() public {
        // 创建一个无法接收 ETH 的合约作为 owner
        NoReceiveETH noReceive = new NoReceiveETH();
        vm.startPrank(owner.addr);
        buyEarth.setOwner(address(noReceive));
        vm.stopPrank();

        // 用户尝试购买地块
        vm.startPrank(user);
        deal(user, PRICE);
        vm.expectRevert("Owner payment failed");
        buyEarth.buySquare{value: PRICE}(1, 0xFF0000);
        vm.stopPrank();

        // 验证地块未被更新
        assertEq(buyEarth.getColor(1), 0);
    }

    // 测试 buySquare 中退款失败场景
    function testBuySquareChangeReturnFailure() public {
        // 创建一个无法接收 ETH 的用户合约
        NoReceiveETH noReceiveUser = new NoReceiveETH();
        address noReceiveAddr = address(noReceiveUser);

        vm.startPrank(noReceiveAddr);
        deal(noReceiveAddr, PRICE * 2);
        vm.expectRevert("Change return failed");
        buyEarth.buySquare{value: PRICE * 2}(1, 0xFF0000);
        vm.stopPrank();

        // 验证地块未被更新
        assertEq(buyEarth.getColor(1), 0);
    }

    // 测试 withdrawTo 中支付失败场景
    function testWithdrawToPaymentFailure() public {
        // 创建一个无法接收 ETH 的接收者合约
        NoReceiveETH noReceiveRecipient = new NoReceiveETH();
        address noReceiveAddr = address(noReceiveRecipient);

        // 向合约注入资金
        deal(address(buyEarth), 1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(noReceiveAddr);
        vm.stopPrank();

        // 验证合约余额未改变
        assertEq(address(buyEarth).balance, 1 ether);
    }

    // 测试 setOwner 的零地址场景
    function testSetOwnerZeroAddress() public {
        vm.startPrank(owner.addr);
        vm.expectRevert("Invalid owner address");
        buyEarth.setOwner(address(0));
        vm.stopPrank();

        // 验证所有者未改变
        assertEq(buyEarth.getOwner(), owner.addr);
    }

    function testReceiveNonZeroAmount() public {
        vm.startPrank(user);
        deal(user, 0.2 ether);

        // 第一次转账：新用户存款
        (bool success1,) = address(buyEarth).call{value: 0.1 ether}("");
        assertTrue(success1);
        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);

        // 第二次转账：已有用户存款
        (bool success2,) = address(buyEarth).call{value: 0.1 ether}("");
        assertTrue(success2);
        assertEq(buyEarth.getUserDeposits(user), 0.2 ether);

        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorList() public {
        // 确保合约有余额但 depositorList 为空
        deal(address(buyEarth), 0.1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.1 ether);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
        // 验证提现成功
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.2 ether);
    }

    function testDeploymentScript() public {
        // 设置 PRIVATE_KEY 环境变量
        vm.setEnv("PRIVATE_KEY", "0x1"); // 测试用私钥

        // 模拟运行部署脚本
        BuyEarthScript script = new BuyEarthScript();
        BuyEarth deployedContract = script.run();

        // 验证初始状态
        assertEq(deployedContract.getOwner(), vm.addr(0x1)); // 私钥 0x1 对应的地址
        uint256[] memory squares = deployedContract.getSquares();
        assertEq(squares.length, 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(squares[i], 0);
        }
    }

    function testOnlyOwnerRestriction() public {
        vm.startPrank(user); // 非所有者
        vm.expectRevert("Only owner can call this function");
        buyEarth.setColor(0, 0xFF0000);
        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorListExtended() public {
        // 确保 depositorList 为空
        assertEq(buyEarth.getUserDeposits(user), 0); // 确认无存款

        // 向合约注入余额
        deal(address(buyEarth), 0.1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.1 ether);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        // 验证提现结果
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.2 ether);
    }

    function testDeploymentScript2() public {
        // 设置 PRIVATE_KEY 环境变量
        vm.setEnv("PRIVATE_KEY", "0x1");

        // 运行部署脚本
        BuyEarthScript script = new BuyEarthScript();
        script.setUp(); // 显式调用 setUp
        script.run();
    }

    function testWithdrawWithEmptyDepositorListExtended2() public {
        // 确保 depositorList 为空
        assertEq(buyEarth.getUserDeposits(user), 0);

        // 注入余额
        deal(address(buyEarth), 0.1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.1 ether);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
        // 验证结果
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.2 ether);
    }

    function testWithdrawWithEmptyDepositorListMinimal() public {
        // 确保 depositorList 为空且无存款
        assertEq(buyEarth.getUserDeposits(user), 0);

        // 注入最小余额
        deal(address(buyEarth), 0.001 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.001 ether);
        buyEarth.deposit{value: 0.001 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        // 验证结果
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.002 ether);
    }

    function testBuySquareOwnerPaymentEdgeCase() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000;
        uint256 price = 0.001 ether;

        // 创建一个无法接收 ETH 的合约作为 owner
        NoReceiveETH noReceive = new NoReceiveETH();
        vm.startPrank(owner.addr);
        buyEarth.setOwner(address(noReceive));
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, price);

        // 期望 owner 支付失败
        vm.expectRevert("Owner payment failed");
        buyEarth.buySquare{value: price}(testIdx, testColor);

        vm.stopPrank();

        // 验证格子未更新
        assertEq(buyEarth.getColor(testIdx), 0);
    }

    function testGetSquaresMemoryEdgeCase() public {
        // 多次调用 getSquares，尝试触发内存分配的边缘情况
        for (uint256 j = 0; j < 10; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares.length, 100);
            for (uint256 i = 0; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }

        // 修改格子后再次调用
        vm.startPrank(owner.addr);
        buyEarth.setColor(0, 0xFF0000);
        vm.stopPrank();

        for (uint256 j = 0; j < 10; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares[0], 0xFF0000);
            for (uint256 i = 1; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }
    }

    function testBuySquareOwnerCallEdgeCase() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000;
        uint256 price = 0.001 ether;

        // 设置 owner 为无法接收 ETH 的合约
        NoReceiveETH noReceive = new NoReceiveETH();
        vm.startPrank(owner.addr);
        buyEarth.setOwner(address(noReceive));
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, price);

        // 测试 owner.call 失败
        vm.expectRevert("Owner payment failed");
        buyEarth.buySquare{value: price}(testIdx, testColor);

        vm.stopPrank();

        // 验证状态未更改
        assertEq(buyEarth.getColor(testIdx), 0);
    }

    function testGetSquaresExtremeStressTest() public {
        // 极高频率调用 getSquares，模拟极端内存压力
        for (uint256 j = 0; j < 1000; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares.length, 100);
            for (uint256 i = 0; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }

        // 修改格子后再次调用
        vm.startPrank(owner.addr);
        buyEarth.setColor(0, 0xFF0000);
        vm.stopPrank();

        for (uint256 j = 0; j < 1000; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares[0], 0xFF0000);
            for (uint256 i = 1; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }
    }
    // 测试所有权转移后的旧所有者权限

    function testOldOwnerPermission() public {
        vm.startPrank(owner.addr);
        buyEarth.setOwner(user2);

        // 旧所有者尝试操作
        vm.expectRevert("Only owner can call this function");
        buyEarth.setColor(1, 0xFF0000);
        vm.stopPrank();
    }

    // 精确验证事件参数
    function testEventParameters() public {
        vm.startPrank(owner.addr);

        // 验证 OwnershipTransferred 事件参数
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(owner.addr, user);
        buyEarth.setOwner(user);

        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorList2() public {
        // 查看合约余额
        assertEq(address(buyEarth).balance, 0);
        // 存款
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        buyEarth.deposit{value: 1 ether}();
        vm.stopPrank();
        assertEq(address(buyEarth).balance, 1 ether);
        assertEq(buyEarth.getUserDeposits(user), 1 ether);
        // 清空存款用户列表
        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt); // 首次提现清空列表
        vm.stopPrank();

        // 再次尝试提现（此时 depositorList 为空）
        deal(address(buyEarth), 1 ether);
        vm.startPrank(owner.addr);
        // vm.expectRevert("No funds to withdraw");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 2 ether);

        // 验证此时合约余额为 0
        assertEq(address(buyEarth).balance, 0);

        // 尝试再次提现（应触发回退）
        vm.startPrank(owner.addr);
        vm.expectRevert("No funds to withdraw");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorListAndBalance() public {
        // 1. 初始化状态
        deal(user, 1 ether);
        vm.prank(user);
        buyEarth.deposit{value: 1 ether}();
        assertEq(address(buyEarth).balance, 1 ether);

        // 2. 首次提现（清空存款列表）
        vm.prank(owner.addr);
        buyEarth.withdrawTo(receipt);
        assertEq(address(buyEarth).balance, 0);

        // 3. 再次提现（存款列表为空且合约余额为 0）
        vm.prank(owner.addr);
        vm.expectRevert("No funds to withdraw");
        buyEarth.withdrawTo(receipt);
    }
}

// 辅助合约：模拟无法接收 ETH 的地址
contract NoReceiveETH {
// 没有 receive 或 fallback 函数，无法接收 ETH
}
