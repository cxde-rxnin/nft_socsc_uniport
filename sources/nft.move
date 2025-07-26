module Obxd::nft {

use sui::event;
use sui::sui::SUI;
use sui::url::{Self, Url};
use std::string::String;
use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use sui::transfer_policy::{Self, TransferPolicy, TransferRequest};
 
const E_INSUFFICIENT_AMOUNT: u64 = 0;

public struct OBXXD <phantom T> has key, store {
    id: UID,
    name: String,
    rarity: u8,
    description: String,
    image_url: Url,
    balance: Balance<T>,
}

public struct NFTminted has copy, drop {
    rarity: u8,
    nft_name: String,
    description: String,
    image_url: Url,
}


#[allow(lint(self_transfer))]
public entry fun mint_nft(
    name: String,
    description: String,
    url_string: String,
    rarity: u8,
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);
    let image_url = url::new_unsafe_from_bytes(url_string.into_bytes());

    let nft: OBXXD<SUI> = OBXXD {
        id: object::new(ctx),
        name,
        rarity,
        description,
        image_url,
        balance: balance::zero<SUI>(),
    };

    event::emit(NFTminted {
        rarity,
        nft_name: name,
        description,
        image_url,
    });

    transfer::public_transfer(nft, sender);
}

public entry fun add_balance<T: store>(
    nft: &mut OBXXD<T>,
    amount: u64,
    _payment: &mut Coin<T>
) { 
    let paid = balance::split(&mut nft.balance, amount);
    balance::join(&mut nft.balance, paid);
}

public entry fun withdraw_balance<T: store>(
    nft: &mut OBXXD<T>,
    amount: u64,
    ctx: &mut TxContext
) {
    let withdrawn = coin::from_balance(
        balance::split(&mut nft.balance, amount),
        ctx
    );
    transfer::public_transfer(withdrawn, tx_context::sender(ctx));
}

public struct Art has key, store {
    id: UID,
    name: String,
    image_url: Url,
    balance: Balance<SUI>,
}

public struct Rule has drop {}
public struct Config has store, drop {}

public fun mint(name: String, url: Url, ctx: &mut TxContext): Art {
    Art {
        id: object::new(ctx),
        name,
        image_url: url,
        balance: balance::zero(),
    }
}

#[allow(lint(share_owned, self_transfer))]
public fun create_policy(publisher: &sui::package::Publisher, ctx: &mut TxContext) {
    let (policy, cap) = transfer_policy::new<Art>(publisher, ctx);
    transfer::public_share_object(policy);
    transfer::public_transfer(cap, tx_context::sender(ctx));
}

public fun pay(
    policy: &mut TransferPolicy<Art>,
    request: &mut TransferRequest<Art>,
    coin: Coin<SUI>
) {
    assert!(coin::value(&coin) == 1_000_000_000, E_INSUFFICIENT_AMOUNT);
    transfer_policy::add_to_balance(Rule {}, policy, coin);
    transfer_policy::add_receipt(Rule {}, request);
}

public fun confirm(
    policy: &TransferPolicy<Art>,
    request: TransferRequest<Art>
) {
    transfer_policy::confirm_request(policy, request);
}

}