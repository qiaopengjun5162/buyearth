// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {BuyEarth} from "../src/BuyEarth.sol";

contract BuyEarthTest is Test {
    BuyEarth public buyEarth;

    Account public owner = makeAccount("owner");
    address public user = makeAddr("user"); // 测试用户地址
    address public user2 = makeAddr("user2"); // 第二个测试用户地址
    address public receipt = makeAddr("receipt"); // 收款地址

    uint256 private PRICE = 0.001 ether;
    event BuySquare(uint8 idx, uint color);
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );
    event ColorChanged(uint8 indexed idx, uint color);
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
        uint[] memory squares = buyEarth.getSquares();
        assertEq(squares.length, 100);
        for (uint i = 0; i < 100; i++) {
            assertEq(squares[i], 0);
        }
    }

    // 测试购买格子
    function testBuySquare() public {
        uint8 testIdx = 1;
        uint testColor = 0xFF0000; // 红色
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
        uint testColor = 0xFF0000;
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
        (bool success, ) = address(buyEarth).call{value: 0.1 ether}("");
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
        buyEarth.withdrawTo(receipt);
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 1 ether);
        vm.stopPrank();
    }

    function testDeposit() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 明确指定调用合约的deposit()
        (bool success, ) = address(buyEarth).call{value: 0.1 ether}(
            abi.encodeWithSignature("deposit()")
        );
        require(success, "Deposit failed");

        vm.stopPrank();

        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);
    }

    function testWithdrawFromDeposit() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 明确指定调用合约的deposit()
        (bool success, ) = address(buyEarth).call{value: 0.1 ether}(
            abi.encodeWithSignature("deposit()")
        );
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
}
