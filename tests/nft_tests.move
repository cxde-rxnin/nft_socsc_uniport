#[test_only]
module nft::nft_tests {
    use sui::test_scenario;
    use sui::tx_context::TxContext;
    use sui::balance;
    use sui::coin;
    use sui::object;
    use sui::url;
    use std::string;
    use nft::OBXXD;
    use nft;

    #[test]
    fun test_mint_nft() {
        let ctx = test_scenario::new_tx_context();
        let name = b"TestNFT";
        let desc = b"A test NFT";
        let url_bytes = b"https://example.com/nft.png";
        let nft_obj = nft::mint_nft<u64>(
            object::new(&mut ctx),
            string::utf8(name),
            string::utf8(desc),
            url::new_unsafe_from_bytes(url_bytes),
            balance::zero()
        );
        // No assert, just check no abort
    }

    #[test]
    fun test_add_and_withdraw_balance() {
        let mut ctx = test_scenario::new_tx_context();
        let name = b"TestNFT";
        let desc = b"A test NFT";
        let url_bytes = b"https://example.com/nft.png";
        let mut nft_obj = OBXXD<u64> {
            id: object::new(&mut ctx),
            name: string::utf8(name),
            rarity: 1,
            description: string::utf8(desc),
            url: url::new_unsafe_from_bytes(url_bytes),
            balance: balance::zero(),
        };
        let mut coin = coin::zero<u64>();
        // Mint some coins for payment
        let mut payment = coin::mint(100, &mut ctx);
        nft::add_balance<u64>(&mut nft_obj, 50, &mut payment);
        // Withdraw
        nft::withdraw_balance<u64>(&mut nft_obj, 25, &mut ctx);
        // No assert, just check no abort
    }
}
