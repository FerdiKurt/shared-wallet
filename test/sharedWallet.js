const SharedWallet = artifacts.require('SharedWallet.sol')
const { expectRevert, expectEvent } = require('@openzeppelin/test-helpers')

function toBN(arg) {
    return web3.utils.toBN(arg)
}

contract('Shared Wallet', accounts => {
    let sharedWallet
    let [acc0, acc1] = accounts
    const addressZero = "0x0000000000000000000000000000000000000000"


    before(async () => {
        sharedWallet = await SharedWallet.new()
    })

    it('should send Ether to the contract', async () => {
        const tx = await sharedWallet.sendTransaction(
            { from: acc0, value: 5000 }
        )  

        const acc0Balance = await sharedWallet.allowances(acc0)
        const walletBalance = await sharedWallet.walletBalance()

        assert.equal(toBN(acc0Balance), 5000)
        assert.equal(toBN(walletBalance), 5000)
        
        await expectEvent(tx, 'ContractReceivedEther', {
            _addr: acc0, 
            _amount: toBN(5000)
        })

    })

    it('shoul NOT add allowance if not owner', async () => {
        await expectRevert(
            sharedWallet.addAllowance(
                acc1,
                2000,
                { from: acc1 }
            ),
            'Only owner!'
        )
    })

    it('should NOT add allowance above available amount', async () => {
        await expectRevert(
            sharedWallet.addAllowance(
                acc1,
                8000,
                { from: acc0 }
            ),
            'Not enough Ether!'
        )
    })

    it('should NOT add allowance to zero address', async () => {
        await expectRevert(
            sharedWallet.addAllowance(
                addressZero,
                2000,
                { from: acc0 }
            ),
            'recipient cannot be zero!'
        )
    })

    it('should ADD allowance', async () => {
        const tx = await sharedWallet.addAllowance(
            acc1, 3000, { from: acc0}
        )
        // console.log(tx)
        assert.equal(tx.receipt.status, true)

        const acc0Balance = await sharedWallet.allowances(acc0)
        const acc1Balance = await sharedWallet.allowances(acc1)
        const walletBalance = await sharedWallet.walletBalance()

        assert.equal(toBN(acc0Balance), 2000)
        assert.equal(toBN(acc1Balance), 3000)
        assert.equal(toBN(walletBalance), 5000)

        await expectEvent(tx, 'AllowanceChanged', {
            _from: acc0,
            _to: acc1,
            _oldAmount: toBN(0),
            _newAmount: toBN(3000)
        })
    })

    it('should NOT reduce allowance if not admin', async () => {
        await expectRevert(
            sharedWallet.reduceAllowance(
                acc1,
                1000,
                { from: acc1 }
            ),
            'Only owner!'
        )
    })

    it('should reduce allowance', async () => {
        const tx = await sharedWallet.reduceAllowance(
            acc1,
            1500,
            { from: acc0 }
        )

        await expectEvent(tx, 'AllowanceChanged', {
            _from: acc0,
            _to: acc1,
            _oldAmount: toBN(3000),
            _newAmount: toBN(1500)
        })
    })

    it('should NOT withdraw Ether above available amount', async () => {
        await expectRevert(
            sharedWallet.withdraw(
                1501,
                { from: acc1 }
            ),
            'Not enough Ether!'
        )
    })

    it('should withdraw Ether', async () => {
        const tx = await sharedWallet.withdraw(
            1000,
            { from: acc1 }
        )

        await expectEvent(tx, 'EtherWithdraw', {
            _to: acc1,
            _amount: toBN(1000)
        })

        const walletBalance = await sharedWallet.walletBalance()
        assert.equal(toBN(walletBalance), 4000)
    })
})
